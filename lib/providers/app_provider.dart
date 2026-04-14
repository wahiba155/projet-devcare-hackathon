import 'package:flutter/material.dart';
import '../services/stress_service.dart';

class AppProvider extends ChangeNotifier {
  int stressScore = 0;
  String currentState = 'calme';
  String currentEmoji = '😌';
  String lastAction = '';
  String lastActionType = '';
  bool isAnalyzing = false;
  int sessionMinutes = 0;
  int inactivityMinutes = 0;
  List<Map<String, dynamic>> stressHistory = [];

  Future<void> analyzeState(String userText) async {
    isAnalyzing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    stressScore = StressService.calculateTextScore(userText);
    currentState = StressService.getStateLabel(stressScore);
    currentEmoji = StressService.getEmoji(stressScore);
    lastAction = _getFallbackAction(currentState);
    lastActionType = 'continue';

    stressHistory.insert(0, {
      'score': stressScore,
      'state': currentState,
      'timestamp': DateTime.now(),
    });

    isAnalyzing = false;
    notifyListeners();
  }

  String _getFallbackAction(String state) {
    switch (state) {
      case 'burnout': return 'Arrête tout. Prends une pause de 20 min minimum.';
      case 'stress': return 'Respire 5 min. Fais une liste de tes priorités.';
      case 'fatigue': return 'Pause de 10 min. Bois de l\'eau.';
      default: return 'Continue comme ça ! Tu es dans le flow. 💪';
    }
  }
}