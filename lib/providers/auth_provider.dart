import 'package:flutter/material.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.idle;
  String errorMessage = '';
  bool isLoggedIn = false;

  Future<bool> signIn(String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        isLoggedIn = true;
        status = AuthStatus.success;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
      String email, String password, String fullName) async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      final user =
          await _authService.signUp(email, password, fullName);

      if (user != null) {
        isLoggedIn = true;
        status = AuthStatus.success;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    isLoggedIn = false;
    status = AuthStatus.idle;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Aucun compte trouvé';
    if (error.contains('wrong-password')) return 'Mot de passe incorrect';
    if (error.contains('email-already-in-use')) return 'Email déjà utilisé';
    if (error.contains('weak-password')) return 'Mot de passe trop faible';
    if (error.contains('invalid-email')) return 'Email invalide';
    return 'Une erreur est survenue';
  }
}