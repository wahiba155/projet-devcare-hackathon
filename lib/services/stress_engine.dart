import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stress_result.dart';
import 'typing_tracker.dart';
import 'inactivity_service.dart';
import 'mental_test_service.dart';

class StressEngine {
  final TypingTracker typingTracker = TypingTracker();
  final InactivityService inactivityService = InactivityService();
  final MentalTestService testService = MentalTestService();

  final String openaiApiKey = "YOUR_OPENAI_API_KEY"; // ⚠️ move to backend in real app

  StressResult analyze({
    required String text,
    required int correctAnswers,
    required int totalQuestions,
    required double reactionTime,
  }) {
    int score = 0;
    List<String> triggers = [];

    // ⌨️ typing
    int typingScore = typingTracker.calculateTypingStress(text);
    score += typingScore;
    if (typingScore > 0) triggers.add("typing_stress");

    // 💤 inactivity
    int inactivityScore = inactivityService.getStressFromInactivity();
    score += inactivityScore;
    if (inactivityScore > 0) triggers.add("inactivity");

    // 🧪 mental test
    int testScore = testService.evaluateTest(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      avgReactionTime: reactionTime,
    );

    score += testScore;
    if (testScore > 0) triggers.add("mental_fatigue");

    if (score > 100) score = 100;

    String state = score < 30
        ? "low"
        : score < 70
        ? "medium"
        : "high";

    // ⚠️ recommendation is now AI-powered (async call)
    return StressResult(
      score: score,
      state: state,
      triggers: triggers,
      recommendation: "Generating AI advice...",
    );
  }

  /// 🤖 REAL AI BRAIN (CALL THIS AFTER analyze)
  Future<String> getAIRecommendation(StressResult result, String text) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openaiApiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
            "You are a mental well-being AI coach for students. Give short, practical advice."
          },
          {
            "role": "user",
            "content":
            "User text: $text\nStress score: ${result.score}\nState: ${result.state}\nTriggers: ${result.triggers}\nGive one short recommendation."
          }
        ],
        "temperature": 0.7
      }),
    );

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }
}