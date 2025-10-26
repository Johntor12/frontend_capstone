// lib/presentation/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_capstone/presentation/pages/list_terminal.dart';
import 'package:flutter_application_capstone/presentation/pages/statistics_page.dart';
import 'package:flutter_application_capstone/presentation/pages/schedule_page.dart';
import 'package:flutter_application_capstone/presentation/pages/settings_mode.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TerminalListPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatisticsPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SchedulingPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingModeScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFA6ACFA),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIcon(context, 0, 'lib/assets/images/device.png'),
            _buildIcon(context, 1, 'lib/assets/images/stats.png'),
            _buildIcon(context, 2, 'lib/assets/images/schedule.png'),
            _buildIcon(context, 3, 'lib/assets/images/mode.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, int index, String assetPath) {
    final bool isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Image.asset(
        assetPath,
        width: isActive ? 32 : 28,
        height: isActive ? 32 : 28,
        color: Colors.white,
      ),
    );
  }
}
