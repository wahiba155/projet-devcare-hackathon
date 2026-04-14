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
      // 🧠 Run the updated engine
      StressResult result = await engine.analyzeAll(userText);

      // 🔁 Update local UI state
      stressScore = result.score;
      currentState = result.state;
      currentEmoji = _getEmoji(result.state);
      lastAction = result.recommendation;
      lastActionType = 'ai';

      // 🔥 Save to Firebase
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await firestore.collection("users").doc(uid).collection("sessions").add({
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