// lib/presentation/pages/list_terminal.dart
import 'package:flutter/material.dart';
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
    // contoh data awal: gunakan priorityOrder, bukan isPriority
    _terminals = List.generate(4, (index) {
      return Terminal(
        id: 't${index + 1}',
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

  void _handlePriorityChange(Terminal t, int? number) {
    setState(() {
      // jika nomor sudah dipakai oleh terminal lain, lepaskan dari terminal lain
      for (var other in _terminals) {
        if (other != t && other.priorityOrder == number) {
          other.priorityOrder = null;
        }
      }
      // assign / toggle
      t.priorityOrder = number;
    });

    // TODO: kirim update ke backend / simpan ke Supabase di sini
    debugPrint('Priority Updated: ${t.id} => ${t.priorityOrder}');
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
