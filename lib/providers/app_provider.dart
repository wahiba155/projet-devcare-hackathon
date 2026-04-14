import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/stress_engine.dart';
import '../services/ai_service.dart'; // 👈 Import AIBrainService
import '../models/stress_result.dart';

class AppProvider extends ChangeNotifier {
  final StressEngine engine = StressEngine();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AIBrainService aiBrain = AIBrainService(); // 👈 Add this

  String get userId => FirebaseAuth.instance.currentUser!.uid;
  final String sessionId = "current";

  int stressScore = 0;
  String currentState = 'low';
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

    // 🧠 1. LOCAL STRESS ENGINE ANALYSIS
    StressResult result = engine.analyze(
      text: userText,
      correctAnswers: 0,
      totalQuestions: 0,
      reactionTime: 0,
    );

    // 🤖 2. SEND TO GEMINI FOR AI RECOMMENDATION
    String aiRecommendation = '';
    try {
      aiRecommendation = await aiBrain.getAdvice(
        score: result.score,
        state: result.state,
        triggers: result.triggers,
        text: userText,
      );
    } catch (e) {
      aiRecommendation = result.recommendation; // fallback to local
      debugPrint('Gemini error: $e');
    }

    // 🔥 3. SAVE TO FIREBASE (with Gemini's recommendation)
    await firestore
        .collection("users")
        .doc(userId)
        .collection("sessions")
        .doc(sessionId)
        .set({
      "text": userText,
      "stressScore": result.score,
      "state": result.state,
      "triggers": result.triggers,
      "recommendation": aiRecommendation, // 👈 Gemini's advice
      "inactivity": inactivityMinutes,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 🔁 4. UPDATE LOCAL STATE
    stressScore = result.score;
    currentState = result.state;
    currentEmoji = _getEmoji(result.state);
    lastAction = aiRecommendation; // 👈 Show Gemini's advice in UI
    lastActionType = 'ai';

    // 📊 5. HISTORY
    stressHistory.insert(0, {
      'score': stressScore,
      'state': currentState,
      'timestamp': DateTime.now(),
      'recommendation': aiRecommendation, // 👈 store it in history too
    });

    isAnalyzing = false;
    notifyListeners();
  }

  String _getEmoji(String state) {
    switch (state) {
      case 'high':
        return '😵';
      case 'medium':
        return '😟';
      case 'low':
      default:
        return '😌';
    }
  }
}