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
    _terminals = List.generate(4, (index) {
      return Terminal(
        id: 'terminal_${index + 1}',
        title: 'Terminal ${index + 1}',
        imagePath: 'lib/assets/images/terminal_icon.png',
      );
    });
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
        "http://10.0.2.2:3000/api/terminals/updatePriority",
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
