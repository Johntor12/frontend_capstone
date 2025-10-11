// lib/widgets/terminal_card.dart

import 'package:flutter/material.dart';
import '../models/terminal.dart';

class TerminalCard extends StatelessWidget {
  final Terminal terminal;
  final ValueChanged<bool> onToggle; // callback ketika switch berubah
  final String variant;

  const TerminalCard({
    super.key,
    required this.terminal,
    required this.onToggle,
    this.variant = "primary",
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == "primary";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          // Left: rounded image box
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFADB4F8),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            child: Image.asset(terminal.imagePath, fit: BoxFit.contain),
          ),

          const SizedBox(width: 24),

          // Right: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPrimary)
                  Container(
                    width: 96,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: terminal.isPriority
                          ? const Color(0xFFDFF8C8)
                          : const Color(0xFFFFD6DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      terminal.isPriority ? 'Prioritas' : 'Tidak Prioritas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: terminal.isPriority
                            ? Colors.green[900]
                            : Colors.red[700],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Title
                Text(
                  terminal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: 120,
                  color: Color(0xFF),
                  child: Row(
                    children: !isPrimary
                        ? [
                            const SizedBox(width: 0),
                            Switch.adaptive(
                              value: terminal.isOn,
                              onChanged: (val) => onToggle(val),
                              activeColor: const Color(
                                0xFF452ABA,
                              ), // purple-ish
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "${terminal.isOn ? 'On' : 'Off'}".toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]
                        : [
                            const SizedBox(width: 0),
                            Switch.adaptive(
                              value: terminal.isOn,
                              onChanged: (val) => onToggle(val),
                              activeColor: const Color(
                                0xFF452ABA,
                              ), // purple-ish
                            ),
                            const Spacer(),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
