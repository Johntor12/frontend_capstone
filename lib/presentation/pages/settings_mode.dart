// lib/presentation/pages/settings_mode.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/terminal.dart';
import '../widgets/manual_terminal_card.dart';
import '../widgets/mode_selector.dart';
import '../widgets/auto_mode_banner.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../core/api_config.dart';
import 'dart:async';

class SettingModeScreen extends StatefulWidget {
  const SettingModeScreen({super.key});

  @override
  State<SettingModeScreen> createState() => _SettingModeScreenState();
}

class _SettingModeScreenState extends State<SettingModeScreen> {
  bool isManual = false; // <-- default ke OTOMATIS
  bool isRunning = false; // apakah knapsack sedang berjalan
  List<Terminal> terminals = [];
  RealtimeChannel? _channel;
  Timer? _statusPollTimer;

  // per-terminal loading state while waiting ack
  final Map<String, bool> _pending = {};

  // timeout for waiting DB ack (ms)
  static const int ackTimeoutMs = 30000;

  @override
  void initState() {
    super.initState();
    _fetchTerminals();
    _setupRealtimeListener();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }

  void _startStatusPolling() {
    // poll immediate then every 2s
    _checkKnapsackStatus();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkKnapsackStatus();
    });
  }

  Future<void> _checkKnapsackStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/knapsack/status'));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        final running = d['running'] == true;
        if (mounted) setState(() => isRunning = running);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _startKnapsackLoop() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/knapsack/start'));
      if (res.statusCode == 200) {
        setState(() => isRunning = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Knapsack started')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start knapsack')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error starting knapsack')),
      );
    }
  }

  Future<void> _stopKnapsackLoop() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/knapsack/stop'));
      if (res.statusCode == 200) {
        setState(() => isRunning = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Knapsack stopped')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to stop knapsack')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error stopping knapsack')),
      );
    }
  }

  Future<void> _fetchTerminals() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/terminals'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List).map((e) {
          return Terminal(
            id: e['terminalId'].toString(),
            title: 'Terminal ${e['terminalId']}',
            imagePath: 'lib/assets/images/terminal_icon.png',
            isOn:
                (e['terminalStatus']?.toString().toLowerCase() ?? 'off') ==
                'on',
            priorityOrder: e['terminalPriority'] == null
                ? null
                : int.tryParse(e['terminalPriority'].toString()),
          );
        }).toList();
        if (mounted) setState(() => terminals = list);
      } else {
        debugPrint('Failed fetch terminals: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetch terminals: $e');
    }
  }

  void _setupRealtimeListener() {
    final supabase = Supabase.instance.client;
    _channel = supabase.channel('public:terminals');

    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'terminals',
      callback: (payload) {
        final updated = payload.newRecord;
        final id = updated['terminalId'].toString();
        final newStatus =
            (updated['terminalStatus']?.toString().toLowerCase() ?? 'off') ==
            'on';

        setState(() {
          final idx = terminals.indexWhere((t) => t.id == id);
          if (idx != -1) terminals[idx].isOn = newStatus;
          if (_pending.containsKey(id) && _pending[id] == true) {
            _pending.remove(id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Terminal $id status updated to ${newStatus ? 'ON' : 'OFF'}',
                ),
              ),
            );
          }
        });
      },
    );

    _channel!.subscribe();
  }

  // function to try toggle manual: newState true=ON, false=OFF
  Future<void> _manualToggle(String terminalId, bool newState) async {
    // find terminal in list
    final idx = terminals.indexWhere((t) => t.id == terminalId);
    if (idx < 0) return;

    // If AUTO mode -> switches should be disabled (but check anyway)
    if (!isManual) return;

    // If knapsack is running -> don't allow manual ON events
    if (isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Algoritma sedang berjalan. Hentikan dulu untuk kontrol manual.',
          ),
        ),
      );
      return;
    }

    // proceed normally (same logic as before)
    setState(() {
      _pending[terminalId] = true;
    });

    final uri = Uri.parse('$baseUrl/terminals/$terminalId/set');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newState ? 'on' : 'off'}),
      );

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final accepted =
            body['accepted'] == true || body['message'] == 'Command published';
        if (!accepted && newState == true) {
          setState(() {
            _pending.remove(terminalId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot turn on: threshold exceeded')),
          );
          await _fetchTerminals();
          return;
        }
        final ok = await _waitForStatusInDb(terminalId, newState, ackTimeoutMs);
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Terminal $terminalId ${newState ? 'turned ON' : 'turned OFF'}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No confirmation from device (timeout).'),
            ),
          );
          await _fetchTerminals();
        }
      } else {
        debugPrint('Backend failed: ${resp.statusCode} ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error when toggling')),
        );
        await _fetchTerminals();
      }
    } catch (e) {
      debugPrint('Error toggling terminal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error when toggling')),
      );
      await _fetchTerminals();
    } finally {
      setState(() {
        _pending.remove(terminalId);
      });
    }
  }

  // ... _waitForStatusInDb remains same as previous code (copy from your file) ...
  Future<bool> _waitForStatusInDb(
    String terminalId,
    bool desiredState,
    int timeoutMs,
  ) async {
    final Completer<bool> completer = Completer<bool>();
    Timer? timer;

    Future<bool> checkOnce() async {
      try {
        final res = await http.get(Uri.parse('$baseUrl/terminals'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final list = (data['data'] as List);
          final found = list
              .where((e) => e['terminalId'] == terminalId)
              .toList();
          if (found.isNotEmpty) {
            final status =
                (found.first['terminalStatus']?.toString().toLowerCase() ??
                    'off') ==
                'on';
            return status == desiredState;
          }
        }
      } catch (e) {
        // ignore
      }
      return false;
    }

    timer = Timer(Duration(milliseconds: timeoutMs), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    final initial = await checkOnce();
    if (initial) {
      timer?.cancel();
      return true;
    }

    final int intervalMs = 1000;
    Timer? pollTimer;
    pollTimer = Timer.periodic(Duration(milliseconds: intervalMs), (t) async {
      final ok = await checkOnce();
      if (ok && !completer.isCompleted) {
        t.cancel();
        timer?.cancel();
        completer.complete(true);
      }
    });

    final result = await completer.future;
    pollTimer?.cancel();
    timer?.cancel();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Setting Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModeSelector(
                isManual: isManual,
                onManualTap: () => setState(() => isManual = true),
                onAutoTap: () => setState(() => isManual = false),
              ),
              const SizedBox(height: 24),
              if (!isManual)
                AutoModeBanner(
                  onStartKnapsack: _startKnapsackLoop,
                  onStopKnapsack: _stopKnapsackLoop,
                  isRunning: isRunning,
                ),
              if (!isManual)
                const Text(
                  "Informasi Terminal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 12),
              ...terminals.map((t) {
                final loading = _pending[t.id] == true;
                // When knapsack is running, manual toggles must be disabled
                final enabled = isManual && !isRunning;
                return ManualTerminalCard(
                  terminal: t,
                  enabled: enabled,
                  loading: loading,
                  onToggle: (val) => _manualToggle(t.id, val),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
