import 'package:flutter/material.dart';

class ModeSelector extends StatelessWidget {
  final bool isManual;
  final VoidCallback onManualTap;
  final VoidCallback onAutoTap;

  const ModeSelector({
    super.key,
    required this.isManual,
    required this.onManualTap,
    required this.onAutoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Manual
        GestureDetector(
          onTap: onManualTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(
              color: isManual ? const Color(0xFFFD9BA6) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Manual',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isManual ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Otomatis
        GestureDetector(
          onTap: onAutoTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            decoration: BoxDecoration(
              color: !isManual ? const Color(0xFFFFA8A8) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Otomatis',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: !isManual ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
