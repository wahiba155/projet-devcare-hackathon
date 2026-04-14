import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wellness_provider.dart';

class RelaxationScreen extends StatelessWidget {
  const RelaxationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WellnessProvider>(context);

    // Formatage du temps restant (MM:SS)
    final String minutesStr = (provider.timeRemaining / 60).floor().toString().padLeft(2, '0');
    final String secondsStr = (provider.timeRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pause & Relaxation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Timer
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text("Timer de Pause", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      "$minutesStr:$secondsStr",
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                    ),
                    const SizedBox(height: 16),
                    provider.isTimerRunning
                        ? ElevatedButton(
                            onPressed: () => provider.stopPauseTimer(),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                            child: const Text("Arrêter la pause"),
                          )
                        : Wrap(
                            spacing: 10,
                            children: [5, 10, 15].map((mins) {
                              return ActionChip(
                                label: Text("$mins min"),
                                onPressed: () => provider.startPauseTimer(mins),
                                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Section Sons
            const Text("Sons Relaxants", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildSoundTile(context, provider, "pluie", "Pluie Apaisante", Icons.water_drop, "audio/pluie.mp3"),
                  _buildSoundTile(context, provider, "foret", "Forêt Profonde", Icons.park, "audio/foret.mp3"),
                  _buildSoundTile(context, provider, "vagues", "Vagues de l'Océan", Icons.waves, "audio/vagues.mp3"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundTile(BuildContext context, WellnessProvider provider, String id, String title, IconData icon, String path) {
    final isPlaying = provider.currentSoundId == id;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C63FF), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
          color: isPlaying ? const Color(0xFF6C63FF) : Colors.grey,
          iconSize: 40,
          onPressed: () => provider.toggleSound(id, path),
        ),
      ),
    );
  }
}