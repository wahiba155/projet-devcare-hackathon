import 'ai_service.dart';
import '../models/stress_result.dart';

class StressEngine {
  final TypingTracker _tracker = TypingTracker();
  final AIBrainService _ai = AIBrainService();

  Future<StressResult> analyzeAll(String text) async {
    // 1. Calculate the real score using keywords + patterns
    int score = _tracker.calculateTypingStress(text);

    // 2. Determine state based on the new logic
    String state = score > 70 ? "high" : (score > 30 ? "medium" : "low");

    // 3. Get Groq AI reasoning
    String recommendation = await _ai.getSmartAdvice(
      score: score,
      state: state,
      userText: text,
    );

    return StressResult(
      score: score,
      state: state,
      triggers: _extractTriggers(text),
      recommendation: recommendation,
    );
  }

  List<String> _extractTriggers(String text) {
    List<String> found = [];
    String input = text.toLowerCase();
    if (input.contains("error") || input.contains("bug")) found.add("coding_issue");
    if (input.contains("tired") || input.contains("dizzy")) found.add("physical_fatigue");
    return found;
  }
}

class TypingTracker {
  int calculateTypingStress(String text) {
    int score = 15; // Base score
    String input = text.toLowerCase();

    // 🔥 KEYWORD BOOSTS (Fixes the "Stuck at 10" issue)
    if (input.contains("tired") || input.contains("exhausted") || input.contains("dizzy")) {
      score += 45;
    }
    if (input.contains("stuck") || input.contains("error") || input.contains("bug")) {
      score += 30;
    }
    if (input.contains("!!!")) score += 15;

    // Caps detection
    if (text.length > 4 && text.toUpperCase() == text) score += 20;

    return score > 100 ? 100 : score;
  }
}
