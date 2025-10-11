import 'package:flutter/material.dart';
import '../models/terminal.dart';
import '../widgets/terminal_card.dart';
import '../widgets/mode_selector.dart';
import '../widgets/auto_mode_banner.dart';

class SettingModeScreen extends StatefulWidget {
  const SettingModeScreen({super.key});

  @override
  State<SettingModeScreen> createState() => _SettingModeScreenState();
}

class _SettingModeScreenState extends State<SettingModeScreen> {
  bool isManual = true;

  final List<Terminal> terminals = [
    Terminal(
      id: "1",
      title: 'Terminal 1',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: true,
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
      isOn: true,
    ),
    Terminal(
      id: "4",
      title: 'Terminal 4',
      imagePath: 'lib/assets/images/terminal_icon.png',
      isOn: false,
    ),
  ];

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
              if (!isManual) const AutoModeBanner(),
              if (!isManual)
                const Text(
                  "Informasi Terminal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 12),
              ...terminals.map(
                (t) => TerminalCard(
                  terminal: t,
                  variant: "secondary",
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
    );
  }
}
