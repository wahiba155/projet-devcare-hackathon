class StressService {
  // Mots-clés pondérés en français et en anglais
  static const Map<String, int> _stressWords = {
    'stressé': 35, 'fatigué': 30, 'épuisé': 45, 'bloqué': 40,
    'perdu': 35, 'pas compris': 38, 'deadline': 42, 'impossible': 40,
    'aide': 25, 'erreur': 20, 'bug': 18, 'nul': 30, 'débordé': 45,
    'stressed': 35, 'tired': 28, 'stuck': 40, 'lost': 33, 'help': 22,
    'overwhelmed': 45, 'burnout': 50, 'exhausted': 45,
  };

  static const Map<String, int> _calmWords = {
    'bien': -15, 'super': -20, 'ok': -10, 'compris': -18,
    'fini': -25, 'terminé': -22, 'réussi': -28, 'cool': -15,
    'good': -15, 'great': -22, 'done': -25, 'finished': -25,
  };

  static int calculateTextScore(String text) {
    int score = 20; // base neutre
    final lower = text.toLowerCase();

    _stressWords.forEach((word, value) {
      if (lower.contains(word)) score += value;
    });

    _calmWords.forEach((word, value) {
      if (lower.contains(word)) score += value; // valeur négative = réduit
    });

    return score.clamp(0, 100);
  }

  static int calculateBehaviorScore({
    required int sessionMinutes,
    required int inactivityMinutes,
  }) {
    int score = 0;
    if (sessionMinutes > 180) score += 40;
    else if (sessionMinutes > 90) score += 20;
    else if (sessionMinutes > 60) score += 10;

    if (inactivityMinutes > 20) score += 35; // bloqué
    else if (inactivityMinutes > 10) score += 15;

    return score.clamp(0, 100);
  }

  static String getStateLabel(int score) {
    if (score >= 75) return 'burnout';
    if (score >= 55) return 'stress';
    if (score >= 35) return 'fatigue';
    return 'calme';
  }

  static String getEmoji(int score) {
    if (score >= 75) return '🔥';
    if (score >= 55) return '😫';
    if (score >= 35) return '😐';
    return '😌';
  }
}