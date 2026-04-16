import 'package:flutter/material.dart'; // 👈 Fixes ChangeNotifier & notifyListeners
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Fixes FirebaseFirestore
import 'package:firebase_auth/firebase_auth.dart';
import '../services/stress_engine.dart'; // 👈 Fixes StressEngine
import '../models/stress_result.dart'; // 👈 Fixes StressResult

class AppProvider extends ChangeNotifier {
  final StressEngine engine = StressEngine();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int stressScore = 0;
  String currentState = 'low';
  String currentEmoji = '😌';
  String lastAction = '';
  String lastActionType = 'none';
  bool isAnalyzing = false;

  Future<void> analyzeState(String userText) async {
  if (userText.trim().isEmpty) return;

  isAnalyzing = true;
  notifyListeners();

  try {
    StressResult result = await engine.analyzeAll(userText);

    stressScore = result.score;
    currentState = result.state;
    currentEmoji = _getEmoji(result.state);
    lastAction = result.recommendation;
    lastActionType = 'ai';

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // ✅ Existing: user-scoped sessions
      await firestore.collection("users").doc(uid).collection("sessions").add({
        "text": userText,
        "score": result.score,
        "state": result.state,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // ✅ NEW: global stress_log with uid for cross-user stats
      await firestore.collection("stress_log").add({
        "uid": uid,                          // 👈 user ID for filtering per user
        "text": userText,
        "score": result.score,
        "state": result.state,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    debugPrint("Provider Error: $e");
    lastAction = "Check your internet connection!";
    lastActionType = 'error';
  }

  isAnalyzing = false;
  notifyListeners();
}

  String _getEmoji(String state) {
    if (state == 'high') return '😵';
    if (state == 'medium') return '😟';
    return '😌';
  }
}