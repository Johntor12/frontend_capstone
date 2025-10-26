// lib/presentation/widgets/terminal_card.dart
import 'package:flutter/material.dart';
import '../models/terminal.dart';

class TerminalCard extends StatelessWidget {
  final Terminal terminal;
  final ValueChanged<int?>
  onSelectPriority; // callback saat pilih/toggle prioritas
  final List<int> usedPriorities; // nomor yang sudah diambil terminal lain
  final String variant; // optional, kalau mau variasi tampilan

  const TerminalCard({
    super.key,
    required this.terminal,
    required this.onSelectPriority,
    required this.usedPriorities,
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
                // Priority label (only for primary variant)
                if (isPrimary)
                  Container(
                    width: 120,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: terminal.priorityOrder != null
                          ? const Color(0xFFDFF8C8)
                          : const Color(0xFFFFD6DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      terminal.priorityOrder != null
                          ? 'Priority #${terminal.priorityOrder}'
                          : 'No Priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: terminal.priorityOrder != null
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

                // Priority buttons (show for primary variant)
                if (isPrimary)
                  Row(
                    children: List.generate(4, (index) {
                      final number = index + 1;
                      final isSelected = terminal.priorityOrder == number;
                      final isUsed =
                          usedPriorities.contains(number) && !isSelected;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: isUsed
                              ? null
                              : () => onSelectPriority(
                                  isSelected ? null : number,
                                ),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6A4DF5)
                                  : isUsed
                                  ? Colors.grey.shade300
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6A4DF5)
                                    : Colors.grey.shade400,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$number',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isUsed
                                    ? Colors.grey
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                // Manual ON/OFF switch (shown if variant != primary)
                if (!isPrimary)
                  Row(
                    children: [
                      Switch.adaptive(
                        value: terminal.isOn,
                        onChanged: (val) {
                          // This widget itself doesn't update model; parent should handle via onSelectPriority if needed
                        },
                        activeColor: const Color(0xFF452ABA),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        terminal.isOn ? 'ON' : 'OFF',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
