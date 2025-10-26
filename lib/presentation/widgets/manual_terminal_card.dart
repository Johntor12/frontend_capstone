import 'package:flutter/material.dart';
import '../models/terminal.dart';

class ManualTerminalCard extends StatelessWidget {
  final Terminal terminal;
  final ValueChanged<bool> onToggle;

  const ManualTerminalCard({
    super.key,
    required this.terminal,
    required this.onToggle,
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
          // 🟣 Gambar Terminal
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

          // 🟢 Teks + Toggle vertikal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Terminal
                Text(
                  terminal.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                // Switch di bawah judul
                Row(
                  children: [
                    Switch(
                      value: terminal.isOn,
                      onChanged: (val) => onToggle(val),
                      activeColor: const Color(0xFF6A4DF5),
                    ),
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
