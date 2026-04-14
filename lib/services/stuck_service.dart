import 'ai_service.dart'; // Assure-toi que ce chemin est correct

class StuckService {
  final AIBrainService _aiService = AIBrainService();

  Future<List<String>> getSuggestions(int stressScore) async {
    // Prompt optimisé pour obtenir 3 actions courtes et actionnables
    final promptText = """
    L'utilisateur est un développeur bloqué dans son travail depuis un moment. 
    Propose 3 actions simples, courtes et bienveillantes pour l'aider à se débloquer.
    Format attendu : une action par ligne, sans numéros ni puces.
    Exemple : 
    Prends un grand verre d'eau
    Divise ta tâche en 3 sous-étapes
    Change d'air pendant 5 minutes
    """;

    try {
      final response = await _aiService.getSmartAdvice(
        score: stressScore,
        state: "Inactif et bloqué",
        userText: promptText,
      );

      // Découpage de la réponse de l'IA en liste de suggestions
      List<String> suggestions = response
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(3) // On s'assure d'en garder max 3
          .toList();

      if (suggestions.isEmpty) throw Exception("Liste vide");
      return suggestions;

    } catch (e) {
      print("Erreur StuckService: $e");
      // Fallback par défaut si l'IA ou le réseau échoue
      return [
        "Prends une pause de 5 minutes loin de l'écran.",
        "Essaie d'expliquer ton problème à haute voix (Rubber Duck).",
        "Découpe ta tâche actuelle en sous-tâches plus petites."
      ];
    }
  }
}