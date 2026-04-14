import 'ai_service.dart';
import 'typing_tracker.dart';
import '../models/stress_result.dart';

class StressEngine {
  final TypingTracker _tracker = TypingTracker();
  final AIBrainService _ai = AIBrainService();

  Future<StressResult> analyzeAll(String text) async {
    // 1. Calculate numerical score (Rule-based/Fast)
    int score = _tracker.calculateTypingStress(text);

    // 2. Determine state
    String state = score > 70 ? "high" : (score > 30 ? "medium" : "low");

    // 3. Get AI Reasoning (Agentic/Smart)
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
    if (text.contains("error")) found.add("coding_error");
    if (text.contains("!!!")) found.add("frustration_typing");
    return found;
  }
}