import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DevCareApp());
}

class DevCareApp extends StatelessWidget {
  const DevCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('DevCare 🧠')),
        body: const Center(
          child: Text('Firebase connecté ! ✅', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}