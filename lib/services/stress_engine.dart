import '../models/stress_result.dart';

class StressDetectionService {

  StressResult analyze({
    required String text,
    required int inactivitySeconds,
  }) {
    int score = 0;
    List<String> triggers = [];

    String input = text.toLowerCase();

    // 🔥 1. Negative keywords
    List<String> stressWords = [
      "stuck",
      "error",
      "bug",
      "can't",
      "cant",
      "frustrated",
      "annoyed",
      "confused",
      "tired",
      "burned out",
      "help"
    ];

    for (String word in stressWords) {
      if (input.contains(word)) {
        score += 15;
        triggers.add("negative_text:$word");
      }
    }

    // ⏱️ 2. Inactivity detection
    if (inactivitySeconds > 300) {
      score += 25;
      triggers.add("long_inactivity");
    } else if (inactivitySeconds > 120) {
      score += 10;
      triggers.add("moderate_inactivity");
    }

    // 🧠 3. Caps / frustration typing
    if (text.contains("!!!") || text.toUpperCase() == text && text.length > 10) {
      score += 10;
      triggers.add("frustration_typing");
    }

    // 🔒 Clamp score
    if (score > 100) score = 100;

    // 📊 State
    String state;
    if (score < 30) {
      state = "low";
    } else if (score < 70) {
      state = "medium";
    } else {
      state = "high";
    }

    return StressResult(
      score: score,
      state: state,
      triggers: triggers,
    );
  }
}
