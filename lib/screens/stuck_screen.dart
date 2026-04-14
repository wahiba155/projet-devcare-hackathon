import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stuck_provider.dart';

class StuckScreen extends StatelessWidget {
  const StuckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stuckProvider = context.watch<StuckProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.psychology_alt,
                size: 80,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(height: 24),
              const Text(
                "Tu sembles bloqué 😕",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "L'inactivité est souvent signe qu'il faut changer d'approche. Voici ce que je te propose :",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Affichage conditionnel (Chargement vs Suggestions)
              if (stuckProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                  ),
                )
              else
                ...stuckProvider.suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      // L'utilisateur choisit d'appliquer ce conseil
                      stuckProvider.ignoreAndResume();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Super choix ! C\'est reparti 💪')),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F2FF), // Violet très clair
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E3FF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFF6C63FF)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

              const SizedBox(height: 40),
              
              // Bouton Ignorer
              TextButton(
                onPressed: () => context.read<StuckProvider>().ignoreAndResume(),
                child: const Text(
                  "Ignorer et continuer mon travail",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}