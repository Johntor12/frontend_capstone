import 'package:flutter/material.dart';

class CustomMenuCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const CustomMenuCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // 🔹 transparan
          shadowColor: Colors.transparent, // 🔹 hilangkan bayangan putih
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero, // 🔹 biar proporsional
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Image.asset(imagePath)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
