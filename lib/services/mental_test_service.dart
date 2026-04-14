class MentalTestService {
  int evaluateTest({
    required int correctAnswers,
    required int totalQuestions,
    required double avgReactionTime,
  }) {
    int score = 0;

    double accuracy = correctAnswers / totalQuestions;

    if (accuracy < 0.5) score += 30;
    else if (accuracy < 0.8) score += 15;

    if (avgReactionTime > 5) score += 20;
    else if (avgReactionTime > 3) score += 10;

    return score;
  }
}