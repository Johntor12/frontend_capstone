// lib/presentation/pages/schedule_form.dart
import 'package:flutter/material.dart';
import '../models/terminal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleForm extends StatefulWidget {
  final List<Map<String, dynamic>> terminals; // from parent GET /api/terminals
  const ScheduleForm({super.key, required this.terminals});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedTerminalId;

  final String baseUrl = 'http://10.0.2.2:3000';

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startTime = picked;
        else
          endTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  bool _terminalHasSchedule(String termId) {
    final found = widget.terminals
        .where((t) => t['terminalId'] == termId)
        .toList();
    if (found.isEmpty) return false;
    return found.first['startOn'] != null;
  }

  Future<void> _submit() async {
    if (selectedTerminalId == null ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    // Compose local DateTime (user timezone assumed Asia/Jakarta). We'll interpret the chosen date/time as local.
    final y = selectedDate!.year;
    final m = selectedDate!.month;
    final d = selectedDate!.day;
    final sHour = startTime!.hour;
    final sMin = startTime!.minute;
    final eHour = endTime!.hour;
    final eMin = endTime!.minute;

    final startLocal = DateTime(y, m, d, sHour, sMin);
    final finishLocal = DateTime(y, m, d, eHour, eMin);

    if (!startLocal.isBefore(finishLocal)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Start must be before End")));
      return;
    }

    // Convert to UTC ISO (server expects ISO timestamptz)
    final startIsoUtc = startLocal.toUtc().toIso8601String();
    final finishIsoUtc = finishLocal.toUtc().toIso8601String();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/terminals/$selectedTerminalId/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'startOn': startIsoUtc, 'finishOn': finishIsoUtc}),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Schedule saved')));
        Navigator.of(context).pop(true); // tell parent to refresh
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${res.body}')));
      }
    } catch (e) {
      debugPrint('Error save schedule: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    // terminals list: build Terminal objects or use widget.terminals
    final terms = widget.terminals;

    return Container(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Add Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Terminal",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: terms.map((t) {
                    final tId = t['terminalId'].toString();
                    final title = '${tId}';
                    final hasSchedule = t['startOn'] != null;
                    final isSelected = selectedTerminalId == tId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: hasSchedule
                            ? null
                            : () => setState(() => selectedTerminalId = tId),
                        child: Opacity(
                          opacity: hasSchedule ? 0.45 : 1.0,
                          child: Container(
                            width: 83,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6A4DF5)
                                  : const Color(0xFFE4E6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  'lib/assets/images/terminal_icon.png',
                                  width: 50,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Container(
                  height: 44,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, true),
                      child: _buildTimeBox("Start", _formatTime(startTime)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, false),
                      child: _buildTimeBox("End", _formatTime(endTime)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA6ACFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text(
                  "SET ON",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String label, String time) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
