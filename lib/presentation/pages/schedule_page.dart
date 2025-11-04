// lib/presentation/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'schedule_form.dart';
import '../widgets/custom_bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  final String baseUrl = 'http://10.0.2.2:3000';
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> allTerminals = []; // raw terminals (for form)

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/terminals'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data'] as List).cast<Map<String, dynamic>>();

        // store all terminals for form usage
        allTerminals = list;

        // filter only those with schedule (startOn != null)
        schedules = list.where((t) => t['startOn'] != null).map((t) {
          final start = DateTime.tryParse(t['startOn'] ?? '');
          final finish = DateTime.tryParse(t['finishOn'] ?? '');
          String dateStr = '';
          String timeStr = '';
          if (start != null && finish != null) {
            // convert to local for display in WIB (we assume device in WIB or want to display in Asia/Jakarta)
            final localStart = start.toLocal();
            final localFinish = finish.toLocal();
            dateStr =
                '${localStart.day.toString().padLeft(2, '0')} ${_monthName(localStart.month)} ${localStart.year}';
            timeStr =
                '${localStart.hour.toString().padLeft(2, '0')}:${localStart.minute.toString().padLeft(2, '0')} - ${localFinish.hour.toString().padLeft(2, '0')}:${localFinish.minute.toString().padLeft(2, '0')}';
          }
          return {
            'terminalId': t['terminalId'],
            'terminalTitle': 'Terminal ${t['terminalId']}',
            'date': dateStr,
            'time': timeStr,
            'startOn': t['startOn'],
            'finishOn': t['finishOn'],
            'image': 'lib/assets/images/terminal_icon.png',
          };
        }).toList();
        setState(() {});
      } else {
        debugPrint('Failed load terminals: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetch schedules: $e');
    }
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  void _openAddSchedule() async {
    // pass allTerminals so form can disable terminals that already have schedule
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleForm(terminals: allTerminals),
    );

    if (result == true) {
      await _fetchSchedules();
    }
  }

  Future<void> _deleteSchedule(String terminalId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/api/terminals/$terminalId/schedule'),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Schedule removed')));
        await _fetchSchedules();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed delete: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Delete schedule error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA6ACFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(item['image'], width: 42, height: 42),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['terminalTitle'],
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
                  onPressed: () => _deleteSchedule(item['terminalId']),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
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
