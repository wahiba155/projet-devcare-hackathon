import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/stress_engine.dart';
import '../services/ai_service.dart'; // Ensure this filename matches
import '../models/stress_result.dart';

class AppProvider extends ChangeNotifier {
  final StressEngine engine = StressEngine();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AIBrainService aiBrain = AIBrainService();

  String? get userId => FirebaseAuth.instance.currentUser?.uid;
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
    final uid = userId;

    if (uid == null) {
      debugPrint("User not logged in");
      return;
    }

    isAnalyzing = true;
    notifyListeners();

    try {
      // 🧠 1. ENGINE ANALYSIS (Updated method name to analyzeAll)
      // Note: We use 'await' because analyzeAll now orchestrates the flow
      StressResult result = await engine.analyzeAll(userText);

      // 🔥 2. SAVE INITIAL STATE TO FIREBASE
      await firestore
          .collection("users")
          .doc(uid)
          .collection("sessions")
          .doc(sessionId)
          .set({
        "text": userText,
        "stressScore": result.score,
        "state": result.state,
        "triggers": result.triggers,
        "recommendation": result.recommendation,
        "inactivity": inactivityMinutes,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 🔁 3. UPDATE UI
      stressScore = result.score;
      currentState = result.state;
      currentEmoji = _getEmoji(result.state);
      lastAction = result.recommendation;
      lastActionType = 'ai'; // It's 'ai' because analyzeAll calls Gemini now

      // 📊 4. HISTORY
      stressHistory.insert(0, {
        "score": stressScore,
        "state": currentState,
        "timestamp": DateTime.now(),
        "recommendation": lastAction,
      });

    } catch (e) {
      debugPrint("Analysis error: $e");
      lastAction = "Connection issue. Stay calm and keep going!";
    }

    isAnalyzing = false;
    notifyListeners();
  }

  // 😊 EMOJI MAPPING
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