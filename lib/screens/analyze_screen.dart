import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});
  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Comment tu te sens ?'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Champ de texte
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ex: "Je suis bloqué sur ce bug depuis 2h, je suis épuisé..."',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton analyser
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: provider.isAnalyzing
                    ? null
                    : () => provider.analyzeState(_controller.text),
                icon: provider.isAnalyzing
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  provider.isAnalyzing ? 'Analyse en cours...' : 'Analyser mon état',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Résultat
            if (provider.stressScore > 0) ...[
              _ResultCard(
                score: provider.stressScore,
                state: provider.currentState,
                emoji: provider.currentEmoji,
                action: provider.lastAction,
                actionType: provider.lastActionType,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int score;
  final String state, emoji, action, actionType;
  const _ResultCard({required this.score, required this.state,
    required this.emoji, required this.action, required this.actionType});

  Color _getColor(BuildContext ctx, int score) {
    if (score >= 75) return Colors.red.shade400;
    if (score >= 55) return Colors.orange.shade400;
    if (score >= 35) return Colors.amber.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context, score);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('Score : $score / 100',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(state.toUpperCase(),
            style: TextStyle(fontSize: 14, color: color, letterSpacing: 2)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_getActionIcon(actionType), color: color),
                const SizedBox(width: 12),
                Expanded(child: Text(action,
                  style: const TextStyle(fontSize: 15, height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'breathing': return Icons.air;
      case 'break': return Icons.free_breakfast;
      case 'hint': return Icons.lightbulb_outline;
      case 'reschedule': return Icons.calendar_today;
      default: return Icons.check_circle_outline;
    }
  }
}