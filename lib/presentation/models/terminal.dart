// lib/models/terminal.dart
class Terminal {
  final String id;
  final String title;
  bool isPriority;
  final String imagePath;
  bool isOn;

  Terminal({
    required this.id,
    required this.title,
    this.isPriority = false,
    required this.imagePath,
    this.isOn = false,
  });
}
