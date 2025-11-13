import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart'; // pastikan baseUrl didefinisikan di sini
import '../widgets/custom_bottom_nav.dart';
import 'dart:math';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedTab = "Daily";
  Map<String, dynamic>? statsData;
  bool loading = true;

  // Fungsi fetch data dari backend
  Future<void> _fetchStatistics() async {
    setState(() => loading = true);
    try {
      final type = selectedTab.toLowerCase(); // daily/monthly/yearly
      final res = await http.get(Uri.parse('$baseUrl/statistics?type=$type'));
      if (res.statusCode == 200) {
        statsData = jsonDecode(res.body);
      } else {
        statsData = null;
      }
    } catch (e) {
      statsData = null;
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    // Data chart dummy hanya untuk tampilan grafik (tidak dihapus)
    final Map<String, List<double>> data = {
      "Daily": List.generate(7, (_) => Random().nextDouble() * 10 + 1),
      "Monthly": List.generate(12, (_) => Random().nextDouble() * 100 + 10),
      "Yearly": List.generate(5, (_) => Random().nextDouble() * 500 + 100),
    };

    final List<dynamic> series = statsData?['series'] ?? [];
    final chartValues = series
        .map((e) => (e['value'] as num).toDouble())
        .toList();
    final double totalPowerGraph = chartValues.isNotEmpty
        ? chartValues.reduce((a, b) => a + b)
        : 0.0;

    // Data dari backend
    final terminalsData = statsData?['terminals'] ?? [];
    final totalKwh = (statsData?['total_kwh'] ?? 0.0) as double;
    final totalCost = (statsData?['total_cost'] ?? 0.0) as double;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),

                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab("Daily"),
                      _buildTab("Monthly"),
                      _buildTab("Yearly"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Grafik Konsumsi",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartValues.reduce(max) + 5,
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
                                final index = value.toInt();
                                if (index >= series.length)
                                  return const SizedBox.shrink();

                                final rawLabel = series[index]['label'] ?? '';
                                String shortLabel = rawLabel;

                                if (selectedTab == "Daily") {
                                  // label berbentuk '2025-11-12' -> ubah ke inisial hari (S, M, T, W, T, F, S)
                                  try {
                                    final date = DateTime.parse(rawLabel);
                                    const days = [
                                      'S',
                                      'M',
                                      'T',
                                      'W',
                                      'T',
                                      'F',
                                      'S',
                                    ];
                                    shortLabel =
                                        days[date.weekday %
                                            7]; // weekday 1=Mon...7=Sun
                                  } catch (_) {
                                    shortLabel = rawLabel;
                                  }
                                } else if (selectedTab == "Monthly") {
                                  // label berbentuk '2025-03' -> ubah ke inisial bulan (J, F, M, A, M, J, J, A, S, O, N, D)
                                  final monthNumber =
                                      int.tryParse(rawLabel.split('-').last) ??
                                      1;
                                  const months = [
                                    'J',
                                    'F',
                                    'M',
                                    'A',
                                    'M',
                                    'J',
                                    'J',
                                    'A',
                                    'S',
                                    'O',
                                    'N',
                                    'D',
                                  ];
                                  shortLabel =
                                      months[(monthNumber - 1).clamp(0, 11)];
                                } else if (selectedTab == "Yearly") {
                                  // label cukup tampilkan 2 digit akhir tahun
                                  shortLabel = rawLabel.substring(
                                    rawLabel.length - 4,
                                  );
                                }

                                return Text(
                                  shortLabel,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(chartValues.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: chartValues[i],
                                color: const Color(0xFFA6ACFA),
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Boxes (pakai data backend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryBox(
                        "Total Pemakaian",
                        "${totalKwh.toStringAsFixed(1)} kWh",
                        const Color(0xFFFCEA34),
                      ),
                      _buildSummaryBox(
                        "Total Biaya",
                        "Rp ${totalCost.toStringAsFixed(0)}",
                        const Color(0xFF88C1FC),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Rekap Pemakaian per Terminal",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  ...terminalsData.map((t) {
                    final double kwh = (t['kwh'] as num).toDouble();
                    final double percentage = totalKwh > 0
                        ? (kwh / totalKwh) * 100
                        : 0;
                    return _buildTerminalCard(t['terminalId'], kwh, percentage);
                  }),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  /// TAB UI
  Widget _buildTab(String label) {
    final bool isActive = selectedTab == label;
    return GestureDetector(
      onTap: () async {
        setState(() => selectedTab = label);
        await _fetchStatistics();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA6ACFA) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Label bawah chart
  Widget _getBottomTitle(int index) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    switch (selectedTab) {
      case "Daily":
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return Text(days[index % 7], style: style);
      case "Monthly":
        const months = [
          'J',
          'F',
          'M',
          'A',
          'M',
          'J',
          'J',
          'A',
          'S',
          'O',
          'N',
          'D',
        ];
        return Text(months[index % 12], style: style);
      case "Yearly":
        final years = List.generate(5, (i) => "${2021 + i}");
        return Text(years[index % 5], style: style);
      default:
        return const Text('');
    }
  }

  /// Kotak total ringkasan (dengan nilai)
  Widget _buildSummaryBox(String label, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Card terminal (ikon + teks + gauge)
  Widget _buildTerminalCard(String name, double power, double percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon Terminal
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE1E5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              "lib/assets/images/terminal_icon.png",
              width: 36,
              height: 36,
            ),
          ),
          const SizedBox(width: 16),
          // Info Terminal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text("${power.toStringAsFixed(1)} kWh"),
              ],
            ),
          ),
          // Gauge persentase
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  color: const Color(0xFF6A4DF5),
                  backgroundColor: Colors.grey[300],
                  strokeWidth: 6,
                ),
                Center(
                  child: Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
