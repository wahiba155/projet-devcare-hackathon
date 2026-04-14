import 'dart:async';
import 'package:flutter/material.dart';
import '../services/stuck_service.dart';

class StuckProvider extends ChangeNotifier {
  final StuckService _stuckService = StuckService();
  
  Timer? _inactivityTimer;
  bool _isStuck = false;
  bool _isLoading = false;
  List<String> _suggestions = [];

  // Constantes de temps
  // 💡 Astuce : Passe à 10 ou 15 secondes pendant tes tests de développement !
  static const Duration inactivityLimit = Duration(minutes: 5); 

  bool get isStuck => _isStuck;
  bool get isLoading => _isLoading;
  List<String> get suggestions => _suggestions;

  void resetInactivityTimer() {
    // Si l'utilisateur est déjà sur l'écran Stuck, on ignore les clics
    if (_isStuck) return; 

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityLimit, _detectInactivity);
  }

  void _detectInactivity() {
    // Ici, tu pourrais récupérer le stress actuel depuis WellnessProvider 
    // si tu injectes le score, pour l'instant on simule un score de 60.
    int currentStressScore = 60; 
    triggerStuckState(currentStressScore);
  }

  Future<void> triggerStuckState(int stressScore) async {
    _isStuck = true;
    _isLoading = true;
    notifyListeners();

    // Option : Calcul d'un "Stuck Score" combiné
    // Ex: stress élevé = IA génère des conseils plus orientés détente que productivité
    _suggestions = await _stuckService.getSuggestions(stressScore);

    _isLoading = false;
    notifyListeners();
  }

  void ignoreAndResume() {
    _isStuck = false;
    _suggestions = [];
    resetInactivityTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}