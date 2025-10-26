// lib/presentation/models/terminal.dart
class Terminal {
  final String id;
  final String title;
  final String imagePath;
  bool isOn;
  int? priorityOrder; // urutan prioritas (1..4) — null jika belum diset

  Terminal({
    required this.id,
    required this.title,
    required this.imagePath,
    this.isOn = false,
    this.priorityOrder,
  });
}
