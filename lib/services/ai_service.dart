import 'dart:convert';
import 'package:http/http.dart' as http;

class AIBrainService {
  // 🔑 Put your Gemini API key here
  final String apiKey = "AIzaSyA1c9NoGSnyKelnh0-4DFyo1AmFa52nZpU";

  Future<String> getSmartAdvice({
    required int score,
    required String state,
    required String userText,
  }) async {
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    // The "System Prompt" that gives the agent its personality
    final prompt = """
    You are an empathetic AI Student Coach. 
    The student's stress score is $score/100 (State: $state).
    They just wrote: "$userText"
    
    Give them one SHORT, supportive sentence of advice. 
    If they seem stuck on a bug, be encouraging. 
    If they are tired, suggest a specific small break.
    """;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      print("Gemini Error: $e");
    }
    return "You're doing great. Take a deep breath!"; // Fallback
  }
}