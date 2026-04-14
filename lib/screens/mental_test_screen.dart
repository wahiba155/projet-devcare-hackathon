import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'analyze_screen.dart';

class MentalTestScreen extends StatefulWidget {
  final String userText;
  const MentalTestScreen({super.key, required this.userText});

  @override
  State<MentalTestScreen> createState() => _MentalTestScreenState();
}

class _MentalTestScreenState extends State<MentalTestScreen> {
  int _currentQuestion = 0;
  final List<int?> _answers = List.filled(5, null);

  final List<Map<String, dynamic>> _questions = [
    {
      'question': "Comment évalues-tu ton niveau d'énergie aujourd'hui ?",
      'emoji': '⚡',
      'options': ["Très faible", "Faible", "Moyen", "Élevé"],
    },
    {
      'question': "As-tu eu du mal à te concentrer aujourd'hui ?",
      'emoji': '🎯',
      'options': ["Tout le temps", "Souvent", "Parfois", "Pas du tout"],
    },
    {
      'question': "Comment as-tu dormi la nuit dernière ?",
      'emoji': '😴',
      'options': ["Très mal", "Mal", "Correctement", "Très bien"],
    },
    {
      'question': "Te sens-tu dépassé(e) par tes tâches ?",
      'emoji': '📚',
      'options': ["Complètement", "Beaucoup", "Un peu", "Pas du tout"],
    },
    {
      'question': "Comment est ton humeur générale en ce moment ?",
      'emoji': '😊',
      'options': ["Très mauvaise", "Mauvaise", "Correcte", "Bonne"],
    },
  ];

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestion] = answerIndex;
    });
  }

  void _next() async {
    if (_answers[_currentQuestion] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choisis une réponse 👆")),
      );
      return;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      final provider = context.read<AppProvider>();

      // 👇 Show loading while Gemini works
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
      );

      await provider.analyzeState(widget.userText);

      if (mounted) {
        Navigator.pop(context); // close loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnalyzeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔙 BACK + PROGRESS
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentQuestion > 0) {
                        setState(() => _currentQuestion--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${_currentQuestion + 1}/${_questions.length}",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ❓ QUESTION
              Text(question['emoji'], style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                question['question'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              // 🔘 OPTIONS
              ...List.generate(
                (question['options'] as List).length,
                    (i) {
                  final selected = _answers[_currentQuestion] == i;
                  return GestureDetector(
                    onTap: () => _selectAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF6C63FF) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: selected
                                ? const Color(0xFF6C63FF).withOpacity(0.3)
                                : Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        question['options'][i],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // ➡️ NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentQuestion < _questions.length - 1 ? "Question suivante →" : "Voir mon analyse 🧠",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}