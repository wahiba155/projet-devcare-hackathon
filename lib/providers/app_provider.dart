import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/stress_service.dart';
import '../services/firebase_service.dart';

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

    try {
      // Score rapide local
      final textScore = StressService.calculateTextScore(userText);
      final behaviorScore = StressService.calculateBehaviorScore(
        sessionMinutes: sessionMinutes,
        inactivityMinutes: inactivityMinutes,
      );
      stressScore = ((textScore + behaviorScore) / 2).round();

      // Appel IA pour raisonnement profond
      final result = await AIService.analyzeUserState(
        userText: userText,
        sessionMinutes: sessionMinutes,
        inactivityMinutes: inactivityMinutes,
      );

      stressScore = result['stress_score'] ?? stressScore;
      currentState = result['state'] ?? StressService.getStateLabel(stressScore);
      currentEmoji = result['emoji'] ?? StressService.getEmoji(stressScore);
      lastAction = result['action'] ?? '';
      lastActionType = result['action_type'] ?? 'continue';

      // Sauvegarder dans Firebase
      await FirebaseService.saveStressEntry(
        score: stressScore,
        state: currentState,
        action: lastAction,
      );

      // Mettre à jour l'historique
      stressHistory.insert(0, {
        'score': stressScore,
        'state': currentState,
        'timestamp': DateTime.now(),
      });

    } catch (e) {
      // Fallback sans API
      stressScore = StressService.calculateTextScore(userText);
      currentState = StressService.getStateLabel(stressScore);
      currentEmoji = StressService.getEmoji(stressScore);
      lastAction = _getFallbackAction(currentState);
    }

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

  void incrementSession() {
    sessionMinutes++;
    if (sessionMinutes % 60 == 0) notifyListeners();
  }
}