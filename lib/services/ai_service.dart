import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIBrainService {
  final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> getSmartAdvice({
    required int score,
    required String state,
    required String userText,
  }) async {
    final url = "https://api.groq.com/openai/v1/chat/completions";

    final prompt = """
      You are a grounded, empathetic Student Stress Coach. Your goal is to provide a stabilizing presence for students. You must mirror the user’s energy—be supportive and calm without being "toxicly positive" or overly bubbly if the student is struggling.

Current Context:

Student Stress Score: $score/100

State: $state

Student’s Message: "$userText"

Response Protocols:

Priority Assessment: If the student uses words like "tired," "dizzy," "stuck," or "burnt out," ignore the numerical score and treat the situation as HIGH STRESS. Safety and well-being come first.

State-Based Tone:

High Stress (>70 or keyword-triggered): Use short, calming sentences. Lower your "energy." Recommend an immediate, non-negotiable mental break (e.g., leaving the room, 5 minutes of breathing).

Moderate/Low Stress: Use encouraging, steady language focused on manageable productivity and balance.

The "Vibe" Check: Do not use exclamation points excessively. Avoid "cheerleading" language if the student expresses pain or exhaustion.

Formatting Instructions:

Support: Open with 1-2 empathetic sentences that validate their specific feeling.

Action Plan: Provide 3-4 actionable suggestions in a bulleted list. Keep these suggestions low-effort (e.g., "Drink a glass of water" rather than "Clean your entire room").  """;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print("Groq Error: ${response.body}");
      }
    } catch (e) {
      print("Connection Error: $e");
    }
    return "Take a deep breath. You're doing your best!";
  }
  Future<Map<String, dynamic>> getSmartDecision({
    required int score,
    required String state,
    required String userText,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final prompt = """
You are an AI productivity coach.

User state:
- Stress score: $score
- State: $state
- Message: "$userText"

Tasks:
$tasks

Respond ONLY in JSON:
{
  "action": "reschedule" or "keep",
  "targetDate": "YYYY-MM-DD",
  "tasksToMove": ["taskId1"],
  "message": "short explanation"
}
""";

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {"role": "user", "content": prompt}
        ]
      }),
    );

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];

    try {
      return jsonDecode(content);
    } catch (e) {
      return {
        "action": "keep",
        "targetDate": null,
        "tasksToMove": [],
        "message": "Keep your schedule for now."
      };
    }
  }
}
