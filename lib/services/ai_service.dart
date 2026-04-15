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
    You are an empathetic Student Stress Coach. 
    The student's stress score is $score/100 (State: $state).
    They said: "$userText"
    
    INSTRUCTIONS:
    - If the score is HIGH (>70), be very calm and suggest an immediate break.
    - If they mention being "tired", "dizzy", or "stuck", PRIORITIZE their words over the numerical score.
    - Give exactly one SHORT, supportive sentence. Do not be overly happy if they feel bad.
    """;

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
}