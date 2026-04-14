import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/stress_engine.dart';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> {
  final StressEngine engine = StressEngine();
  final TextEditingController controller = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String userId = "user1";
  final String sessionId = "current";

  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DevCare AI Agent")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🧠 INPUT
            TextField(
              controller: controller,
              onChanged: (text) async {

                // 🤖 1. RUN AGENT ENGINE
                final res = engine.analyze(
                  text: text,
                  correctAnswers: 3,
                  totalQuestions: 5,
                  reactionTime: 4.0,
                );

                // 🔥 2. SAVE TO FIREBASE (agent memory)
                await firestore
                    .collection("users")
                    .doc(userId)
                    .collection("sessions")
                    .doc(sessionId)
                    .set({
                  "text": text,
                  "stressScore": res.score,
                  "state": res.state,
                  "triggers": res.triggers,
                  "recommendation": res.recommendation,
                  "updatedAt": FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                // 🖥️ 3. UPDATE UI
                setState(() {
                  result =
                  "Score: ${res.score}\nState: ${res.state}\nAdvice: ${res.recommendation}";
                });
              },
              decoration: const InputDecoration(
                hintText: "Type your thoughts...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 📊 OUTPUT
            Text(
              result,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // 💤 MANUAL INACTIVITY BUTTON (hackathon feature)
            ElevatedButton(
              onPressed: () async {
                await firestore
                    .collection("users")
                    .doc(userId)
                    .collection("sessions")
                    .doc(sessionId)
                    .update({
                  "manualInactive": true,
                  "state": "inactive",
                  "recommendation": "User marked as inactive 💤"
                });

                setState(() {
                  result = "User marked as inactive 💤";
                });
              },
              child: const Text("Set Inactive (Demo)"),
            ),
          ],
        ),
      ),
    );
  }
}