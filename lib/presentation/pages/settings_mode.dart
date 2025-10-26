// lib/presentation/pages/settings_mode.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/terminal.dart';
import '../widgets/manual_terminal_card.dart';
import '../widgets/mode_selector.dart';
import '../widgets/auto_mode_banner.dart';
import '../widgets/custom_bottom_nav.dart';

class SettingModeScreen extends StatefulWidget {
  const SettingModeScreen({super.key});

  @override
  State<SettingModeScreen> createState() => _SettingModeScreenState();
}

class _SettingModeScreenState extends State<SettingModeScreen> {
  bool isManual = true;
  bool isLoading = false;

  List<Terminal> terminals = [
    Terminal(
      id: "1",
      title: 'Terminal 1',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: false,
    ),
    Terminal(
      id: "2",
      title: 'Terminal 2',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: false,
    ),
    Terminal(
      id: "3",
      title: 'Terminal 3',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: false,
    ),
    Terminal(
      id: "4",
      title: 'Terminal 4',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: false,
    ),
  ];

  Future<void> _runKnapsack() async {
    setState(() => isLoading = true);

    try {
      // contoh body dummy yang dikirim ke backend
      final body = jsonEncode({
        "terminals": [
          {"id": 1, "power": 500, "priority": 1},
          {"id": 2, "power": 300, "priority": 2},
          {"id": 3, "power": 200, "priority": 3},
          {"id": 4, "power": 100, "priority": 4},
        ],
        "max_power": 700,
      });

      // 🔗 ganti URL ini ke backend-mu nanti (dummy)
      final res = await http.post(
        Uri.parse("http://localhost:3000/run-knapsack"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);

        // result contoh: {"activeTerminals": [1,3]}
        List active = result["activeTerminals"];

        setState(() {
          for (var t in terminals) {
            t.isOn = active.contains(int.parse(t.id));
          }
        });
      } else {
        print("Failed: ${res.statusCode}");
      }
    } catch (e) {
      print("Error running knapsack: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Setting Mode",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModeSelector(
                isManual: isManual,
                onManualTap: () => setState(() => isManual = true),
                onAutoTap: () => setState(() => isManual = false),
              ),
              const SizedBox(height: 24),
              if (!isManual)
                AutoModeBanner(
                  onStartKnapsack: _runKnapsack,
                  isLoading: isLoading,
                ),
              if (!isManual)
                const Text(
                  "Informasi Terminal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 12),
              ...terminals.map(
                (t) => ManualTerminalCard(
                  terminal: t,
                  onToggle: (val) {
                    setState(() => t.isOn = val);
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
