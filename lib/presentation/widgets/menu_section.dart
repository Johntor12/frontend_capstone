import 'package:flutter/material.dart';
import 'package:flutter_application_capstone/presentation/pages/list_terminal.dart';
import 'package:flutter_application_capstone/presentation/pages/schedule_page.dart';
import 'package:flutter_application_capstone/presentation/pages/settings_mode.dart';
import 'package:flutter_application_capstone/presentation/pages/statistics_page.dart';
import 'package:flutter_application_capstone/presentation/widgets/custom_menu_card.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        child: GridView.count(
          crossAxisCount: 2, // Dua kolom
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1, // supaya bentuknya hampir kotak
          children: [
            CustomMenuCard(
              title: "Device Priority",
              imagePath: "lib/assets/images/device_priority_image.png",
              backgroundColor: Color(0xFF7AB8F5),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TerminalListPage()),
                );
              },
            ),
            CustomMenuCard(
              title: "Usage Overview",
              imagePath: "lib/assets/images/usage_overview_image.png",
              backgroundColor: Color(0xFFFFA8A8),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StatisticsPage()),
                );
              },
            ),
            CustomMenuCard(
              title: "Smart Scheduling",
              imagePath: "lib/assets/images/smart_scheduling_image.png",
              backgroundColor: Color(0xFFFFCE94),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => SchedulePage()));
              },
            ),
            CustomMenuCard(
              title: "Control Modes",
              imagePath: "lib/assets/images/control_modes_image.png",
              backgroundColor: Color(0xFFA6A5FF),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingModeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
