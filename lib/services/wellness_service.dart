import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class WellnessService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  // --- Gestion audio ---
  Future<void> playSound(String path) async {
    // Utilise AssetSource pour lire depuis le dossier assets/
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Boucle le son relaxant
    await _audioPlayer.play(AssetSource(path));
  }

  Future<void> pauseSound() async {
    await _audioPlayer.pause();
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  // --- Gestion Timer ---
  void startTimer(int durationSeconds, Function(int) onTick, Function onComplete) {
    _timer?.cancel();
    int remaining = durationSeconds;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining > 0) {
        remaining--;
        onTick(remaining);
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
  }
}