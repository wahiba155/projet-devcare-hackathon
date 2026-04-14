import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AIBrainService {
  final String apiKey = "AIzaSyA1c9NoGSnyKelnh0-4DFyo1AmFa52nZpU"; // 🔑

  Future<String> getAdvice({
    required int score,
    required String state,
    required List<String> triggers,
    required String text,
  }) async {
    // 👤 Pull user info from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Student';
    final userEmail = user?.email ?? '';

    final prompt = """
You are a mental health AI coach for students.

User: $userName ($userEmail)
- Stress score: $score / 100
- State: $state
- Triggers: ${triggers.join(', ')}
- What they wrote: "$text"

Give a SHORT, practical recommendation (max 2 sentences).
Address them by first name if possible. Be calm, supportive, and actionable.
""";

    final response = await http.post(
      Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data["candidates"][0]["content"]["parts"][0]["text"];
  }
}