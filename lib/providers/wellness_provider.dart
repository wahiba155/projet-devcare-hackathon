import 'package:flutter/material.dart';
import '../services/wellness_service.dart';

class WellnessProvider with ChangeNotifier {
  final WellnessService _wellnessService = WellnessService();

  // État Respiration
  bool _isBreathing = false;
  bool get isBreathing => _isBreathing;

  // État audio
  String? _currentSoundId;
  String? get currentSoundId => _currentSoundId;

  // État Timer
  int _timeRemaining = 0;
  int get timeRemaining => _timeRemaining;
  bool _isTimerRunning = false;
  bool get isTimerRunning => _isTimerRunning;

  void toggleBreathing() {
    _isBreathing = !_isBreathing;
    notifyListeners();
  }

  void toggleSound(String id, String assetPath) {
    if (_currentSoundId == id) {
      _wellnessService.pauseSound();
      _currentSoundId = null;
    } else {
      _wellnessService.playSound(assetPath);
      _currentSoundId = id;
    }
    notifyListeners();
  }

  void startPauseTimer(int minutes) {
    _isTimerRunning = true;
    _timeRemaining = minutes * 60;
    notifyListeners();

    _wellnessService.startTimer(
      _timeRemaining,
      (remaining) {
        _timeRemaining = remaining;
        notifyListeners();
      },
      () {
        _isTimerRunning = false;
        notifyListeners();
      },
    );
  }

  void stopPauseTimer() {
    _wellnessService.stopTimer();
    _isTimerRunning = false;
    _timeRemaining = 0;
    notifyListeners();
  }

  void stopAll() {
    _wellnessService.stopSound();
    _wellnessService.stopTimer();
    _currentSoundId = null;
    _isBreathing = false;
    _isTimerRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _wellnessService.dispose();
    super.dispose();
  }
}