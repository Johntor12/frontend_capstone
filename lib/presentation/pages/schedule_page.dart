import 'package:flutter/material.dart';
import 'schedule_form.dart';

import '../widgets/custom_bottom_nav.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  final List<Map<String, dynamic>> schedules = [
    {
      "terminal": "Terminal 1",
      "date": "21 Oct 2025",
      "time": "18:00 - 19:00",
      "image": "lib/assets/images/terminal_icon.png",
    },
    {
      "terminal": "Terminal 2",
      "date": "21 Oct 2025",
      "time": "20:00 - 22:00",
      "image": "lib/assets/images/terminal_icon.png",
    },
  ];

  void _openAddSchedule() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScheduleForm(),
    );

    if (result != null) {
      setState(() {
        schedules.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Scheduling",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final item = schedules[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon terminal
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA6ACFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(item['image'], width: 42, height: 42),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['terminal'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['date'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        item['time'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      schedules.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),

      // Floating button ➕
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA6ACFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: _openAddSchedule,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
