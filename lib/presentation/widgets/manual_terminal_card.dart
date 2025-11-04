// lib/presentation/widgets/manual_terminal_card.dart
import 'package:flutter/material.dart';
import '../models/terminal.dart';

class ManualTerminalCard extends StatelessWidget {
  final Terminal terminal;
  final ValueChanged<bool> onToggle;
  final bool enabled;
  final bool loading;

  const ManualTerminalCard({
    super.key,
    required this.terminal,
    required this.onToggle,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE1E5FF),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              terminal.imagePath,
              fit: BoxFit.contain,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  terminal.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (loading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Switch(
                        value: terminal.isOn,
                        onChanged: enabled
                            ? (val) => onToggle(val)
                            : (val) {
                                // jika disabled, beri notifikasi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Algoritma sedang berjalan. Hentikan untuk kontrol manual.',
                                    ),
                                  ),
                                );
                              },
                        activeColor: const Color(0xFF6A4DF5),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      terminal.isOn ? "ON" : "OFF",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: terminal.isOn
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
