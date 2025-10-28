// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/widgets/header_section.dart';
import 'presentation/widgets/info_banner.dart';
import 'presentation/widgets/menu_section.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://pxbruhibrrvjakylysxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4YnJ1aGlicnJ2amFreWx5c3h6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MzMwODYsImV4cCI6MjA3NDMwOTA4Nn0.rJaKi-YSz1ORCvXPICcxIvOyq2jZ8lja21pluZzcRkM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //Home page sekarang adalah MyHomePage dengan MenuSection
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const HeaderSection(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              InfoBanner(),
              SizedBox(height: 16),
              Expanded(child: MenuSection()),
            ],
          ),
        ),
      ),
    );
  }
}
