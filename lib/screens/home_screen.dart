import 'package:flutter/material.dart';
import 'analyze_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevCare 🧠'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😌', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'Comment tu te sens aujourd\'hui ?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyzeScreen()),
              ),
              icon: const Icon(Icons.psychology),
              label: const Text('Analyser mon état'),
            ),
          ],
        ),
      ),
    );
  }
}