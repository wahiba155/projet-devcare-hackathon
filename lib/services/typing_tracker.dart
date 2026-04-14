class TypingTracker {
  String lastText = "";
  DateTime lastTime = DateTime.now();

  int calculateTypingStress(String text) {
    int score = 0;

    // speed detection
    final now = DateTime.now();
    final diff = now.difference(lastTime).inMilliseconds;

    if (diff < 500) {
      score += 10; // fast typing
    }

    // backspace / rewrite detection
    if (text.length < lastText.length) {
      score += 15;
    }

    // frustration patterns
    if (text.contains("!!!") || text.toUpperCase() == text && text.length > 5) {
      score += 10;
    }

    lastText = text;
    lastTime = now;

    return score;
  }
}