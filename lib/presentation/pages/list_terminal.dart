// lib/pages/terminal_list_page.dart
import 'package:flutter/material.dart';
import '../models/terminal.dart';
import '../widgets/terminal_card.dart';

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
    // contoh data awal
    _terminals = List.generate(4, (index) {
      return Terminal(
        id: 't${index + 1}',
        title: 'Terminal ${index + 1}',
        isPriority: index % 2 == 0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Terminal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
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

              // list
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
                          onToggle: (val) {
                            setState(() {
                              t.isPriority = val; // update model
                            });
                          },
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
    );
  }
}
