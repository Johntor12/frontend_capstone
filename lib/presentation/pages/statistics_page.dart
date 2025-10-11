import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/terminal.dart';
import '../widgets/terminal_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Terminal> terminals = [
    Terminal(
      id: "1",
      title: "Terminal X",
      imagePath: "lib/assets/images/terminal_icon.png",
      isPriority: true,
    ),
    Terminal(
      id: '2',
      title: "Terminal X",
      imagePath: "lib/assets/images/terminal_icon.png",
      isPriority: false,
    ),
    Terminal(
      id: "3",
      title: "Terminal X",
      imagePath: "lib/assets/images/terminal_icon.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text(
                "Statistics",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Daily", true),
                _buildTab("Monthly", false),
                _buildTab("Yearly", false),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Grafik", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Mon', style: style);
                            case 1:
                              return const Text('Tue', style: style);
                            case 2:
                              return const Text('Wed', style: style);
                            case 3:
                              return const Text('Thu', style: style);
                            case 4:
                              return const Text('Fri', style: style);
                            case 5:
                              return const Text('Sat', style: style);
                            case 6:
                              return const Text('Sun', style: style);
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: 6, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: 4, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(toY: 8, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(toY: 9, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(toY: 3, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(toY: 7, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(toY: 5, color: const Color(0xFFA6ACFA)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBox("Total Pemakaian", const Color(0xFFFCEA34)),
                _buildSummaryBox("Total Biaya", const Color(0xFF88C1FC)),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Recap Pemakaian /terminal",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...terminals.map(
              (t) => TerminalCard(
                terminal: t,
                onToggle: (val) => setState(() => t.isPriority = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA6ACFA) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
