import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = 'sk-VOTRE_CLE_OPENAI'; // remplacer

  static Future<Map<String, dynamic>> analyzeUserState({
    required String userText,
    required int sessionMinutes,
    required int inactivityMinutes,
  }) async {
    final prompt = '''
Tu es un agent IA spécialisé dans le bien-être des étudiants et développeurs.

Contexte utilisateur :
- Message : "$userText"
- Durée de session : ${sessionMinutes} minutes
- Inactivité récente : ${inactivityMinutes} minutes

Analyse l'état mental et réponds UNIQUEMENT en JSON avec ce format :
{
  "stress_score": <0-100>,
  "state": "<calme|fatigue|stress|burnout|bloque>",
  "emoji": "<emoji adapté>",
  "reason": "<raison courte en français>",
  "action": "<action recommandée>",
  "action_type": "<breathing|break|hint|reschedule|continue>"
}
''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 300,
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      // Nettoyer le JSON (retirer les backticks si présents)
      final clean = content.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean);
    }
    throw Exception('Erreur API OpenAI: ${response.statusCode}');
  }
}