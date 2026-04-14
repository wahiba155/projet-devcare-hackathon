import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
import 'package:provider/provider.dart';
import '../providers/wellness_provider.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _instruction = "Prêt ?";

  @override
  void initState() {
    super.initState();
    // Cycle de 4 secondes pour inspirer, 4 secondes pour expirer
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = "Expire...");
        HapticFeedback.lightImpact(); // Vibration légère
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = "Inspire...");
        HapticFeedback.lightImpact();
        _controller.forward();
      }
    });
  }

  void _toggleBreathing(WellnessProvider provider) {
    provider.toggleBreathing();
    if (provider.isBreathing) {
      setState(() => _instruction = "Inspire...");
      _controller.forward();
    } else {
      setState(() => _instruction = "Prêt ?");
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wellnessProvider = Provider.of<WellnessProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Respiration Guidée', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _instruction,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
            ElevatedButton.icon(
              onPressed: () => _toggleBreathing(wellnessProvider),
              icon: Icon(wellnessProvider.isBreathing ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 28),
              label: Text(wellnessProvider.isBreathing ? "Arrêter" : "Démarrer", style: const TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                backgroundColor: wellnessProvider.isBreathing ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}