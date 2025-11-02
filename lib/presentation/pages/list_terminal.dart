// lib/presentation/pages/list_terminal.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../models/terminal.dart';
import '../widgets/terminal_card.dart';
import '../widgets/custom_bottom_nav.dart';

class TerminalListPage extends StatefulWidget {
  const TerminalListPage({super.key});

  @override
  State<TerminalListPage> createState() => _TerminalListPageState();
}

class _TerminalListPageState extends State<TerminalListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Terminal> _terminals = [];

  @override
  void initState() {
    super.initState();
    _fetchTerminals();
  }

  Future<void> _fetchTerminals() async {
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/terminals"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _terminals = (data['data'] as List)
              .map(
                (e) => Terminal(
                  id: e['terminalId'].toString(),
                  title: "Terminal ${e['terminalId']}",
                  imagePath: "lib/assets/images/terminal_icon.png",
                  isOn:
                      (e['terminalStatus']?.toString().toLowerCase() ??
                          'off') ==
                      'on',
                  priorityOrder: e['terminalPriority'] == 0
                      ? null
                      : int.tryParse(e['terminalPriority'].toString()),
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint("fetch error: $e");
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Terminal> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _terminals;
    return _terminals.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  // daftar nomor prioritas yang sudah dipakai
  List<int> get usedPriorities => _terminals
      .where((t) => t.priorityOrder != null)
      .map((t) => t.priorityOrder!)
      .toList();

  //kirim data ke backend
  Future<void> _handlePriorityChange(Terminal t, int? number) async {
    setState(() {
      for (var other in _terminals) {
        if (other != t && other.priorityOrder == number) {
          other.priorityOrder = null;
        }
      }
      t.priorityOrder = number;
    });

    debugPrint('Priority Updated: ${t.id} => ${t.priorityOrder}');

    try {
      final url = Uri.parse(
        "http://10.0.2.2:3000/api/knapsack/terminals/updatePriority",
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'terminalId': t.id, 'priority': t.priorityOrder}),
      );

      if (response.statusCode == 200) {
        debugPrint('Priority updated on backend');
      } else {
        debugPrint('Failed to update priority: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Priority',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: 'Cari terminal...',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B38CB), // ungu benar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Map<String, int?> map = {};
                        for (var t in _terminals) {
                          map[t.id] = t.priorityOrder;
                        }
                        final res = await http.post(
                          Uri.parse(
                            "http://10.0.2.2:3000/api/terminals/savePrioritiesAutoFill",
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(map),
                        );
                        if (res.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saved")),
                          );
                          await _fetchTerminals();
                        }
                      },
                      child: const Text(
                        "Save Priority",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD7D8A), // pink benar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await http.post(
                          Uri.parse(
                            "http://10.0.2.2:3000/api/terminals/resetPriorities",
                          ),
                        );
                        await _fetchTerminals();
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = _filtered[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TerminalCard(
                          terminal: t,
                          usedPriorities: usedPriorities,
                          onSelectPriority: (number) =>
                              _handlePriorityChange(t, number),
                          variant: "primary",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
