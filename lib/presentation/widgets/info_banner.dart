import 'package:flutter/material.dart';
import '../../core/widgets/app_colors.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 177,
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
          // Image section
          child: Image.asset(
            'lib/assets/images/hero_robot_image.png',
            width: 140,
            fit: BoxFit.contain,
          ),
          ),
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Optimize your power consumption with IoT-based",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: [
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Text(
                        "Smart Load Controller",
                        style: TextStyle(
                          color: AppColors.purple300,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
