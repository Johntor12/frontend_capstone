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
import 'dart:async';

class SettingModeScreen extends StatefulWidget {
  const SettingModeScreen({super.key});

  @override
  State<SettingModeScreen> createState() => _SettingModeScreenState();
}

class _SettingModeScreenState extends State<SettingModeScreen> {
  bool isManual = true;
  bool isLoading = false;
  final String baseUrl =
      'http://10.0.2.2:3000'; // gunakan 10.0.2.2 untuk emulator Android
  List<Terminal> terminals = [];
  RealtimeChannel? _channel;

  // per-terminal loading state while waiting ack
  final Map<String, bool> _pending = {};

  // timeout for waiting DB ack (ms)
  static const int ackTimeoutMs = 8000;

  @override
  void initState() {
    super.initState();
    _fetchTerminals();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchTerminals() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/terminals'));
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
        setState(() {
          terminals = list;
        });
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
          // if we were waiting for ack, check if matches desired state and clear pending
          if (_pending.containsKey(id) && _pending[id] == true) {
            // we need to know what desired state was - we can track desired in _pendingDesired
            // For simplicity: when pending true, we clear it and notify success if status matches
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

        debugPrint(
          'Realtime update -> Terminal $id: ${newStatus ? "ON" : "OFF"}',
        );
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

    // If newState == true (user wants ON), we must ask backend to check threshold
    // If newState == false (OFF), we send directly but still verify DB ack.
    setState(() {
      _pending[terminalId] = true; // mark loading
    });

    // Show spinner in card (via _pending map)
    final uri = Uri.parse('$baseUrl/api/terminals/$terminalId/set');
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
          // Backend rejected turning ON due capacity -> show notification and stop pending
          setState(() {
            _pending.remove(terminalId);
            // revert local toggle state to value from DB (refresh)
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot turn on: threshold exceeded')),
          );
          // Refresh current terminals from backend
          await _fetchTerminals();
          return;
        }
        // If accepted, we now wait for DB realtime update (ACK from device) within timeout
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
          // refresh from backend to read actual state
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

  // wait for DB status to match desiredState, polling briefly or rely on realtime (we use both)
  Future<bool> _waitForStatusInDb(
    String terminalId,
    bool desiredState,
    int timeoutMs,
  ) async {
    final Completer<bool> completer = Completer<bool>();
    Timer? timer;

    // quick check function
    Future<bool> checkOnce() async {
      try {
        final res = await http.get(Uri.parse('$baseUrl/api/terminals'));
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

    // listen realtime temporary
    void realtimeListener(dynamic payload) {
      // If realtime updated, we can check
      checkOnce().then((match) {
        if (match && !completer.isCompleted) {
          completer.complete(true);
        }
      });
    }

    // start timer for timeout
    timer = Timer(Duration(milliseconds: timeoutMs), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    // do immediate check
    final initial = await checkOnce();
    if (initial) {
      timer?.cancel();
      return true;
    }

    // fallback: poll every 1s until timeout (also realtime may help)
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

  Future<void> _runKnapsack() async {
    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/knapsack/run'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);
        final active = List<String>.from(result['data']['selected'] ?? []);
        // We DO NOT set isOn directly from backend output; final state will come from DB realtime.
        // But for visual feedback we can mark pending states (optional)
        // We leave UI update to realtime to ensure authoritative state.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Knapsack executed; awaiting device confirmations'),
          ),
        );
      } else {
        debugPrint('Failed run knapsack: ${res.statusCode}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Knapsack run failed')));
      }
    } catch (e) {
      debugPrint('Error running knapsack: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error running knapsack')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
                  onStartKnapsack: _runKnapsack,
                  isLoading: isLoading,
                ),
              if (!isManual)
                const Text(
                  "Informasi Terminal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 12),
              ...terminals.map((t) {
                final loading = _pending[t.id] == true;
                return ManualTerminalCard(
                  terminal: t,
                  enabled: isManual,
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
