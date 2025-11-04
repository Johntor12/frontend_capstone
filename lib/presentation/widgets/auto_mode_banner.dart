// lib/presentation/widgets/auto_mode_banner.dart
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';

class AutoModeBanner extends StatelessWidget {
  final VoidCallback onStartKnapsack; // Callback ke parent FE (mulai)
  final VoidCallback onStopKnapsack; // Callback stop
  final bool isRunning;

  const AutoModeBanner({
    super.key,
    required this.onStartKnapsack,
    required this.onStopKnapsack,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFA6ACFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Algoritma\nKnapsack",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4DF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isRunning ? null : onStartKnapsack,
                    child: const Text(
                      "START →",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? const Color(0xFFFD7D8A)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isRunning ? onStopKnapsack : null,
                    child: isRunning
                        ? Row(
                            children: const [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'STOP',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'STOP',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Image.asset('lib/assets/images/AI_head.png', width: 120),
        ],
      ),
    );
  }
}
