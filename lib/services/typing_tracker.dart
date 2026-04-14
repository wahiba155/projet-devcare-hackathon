class TypingTracker {
  int calculateTypingStress(String text) {
    // 1. Start with a very low base
    int score = 10;
    String input = text.toLowerCase();

    // 2. 🚨 KEYWORD DETECTION (Add more keywords here!)
    // If any of these are found, the score JUMPS.
    Map<String, int> triggers = {
      "tired": 40,
      "exhausted": 50,
      "dizzy": 45,
      "stuck": 30,
      "error": 25,
      "bug": 25,
      "help": 20,
      "bloqué": 35, // Added French for your example text
      "épuisé": 45,
    };

    triggers.forEach((word, points) {
      if (input.contains(word)) {
        score += points;
      }
    });

    // 3. ⌨️ PATTERN DETECTION
    // High Caps = Frustration
    if (text.length > 4 && text.toUpperCase() == text) {
      score += 25;
    }

    // Frantic punctuation
    if (text.contains("!!!")) {
      score += 15;
    }

    // 4. 🔒 CLAMP SCORE (0-100)
    if (score > 100) score = 100;

    return score;
  }
}
