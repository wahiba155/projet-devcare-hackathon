import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'analyze_screen.dart';
import 'mental_test_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final fullName =
        "${_firstNameController.text} ${_lastNameController.text}";

    final success = _isSignUp
        ? await auth.signUp(
            _emailController.text,
            _passwordController.text,
            fullName,
          )
        : await auth.signIn(
            _emailController.text,
            _passwordController.text,
          );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StressScreen(), // 👈 TON NAVIGATION
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: Center(
        child: SingleChildScrollView(

          // 🧠 CARTE CENTRÉE
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  // 🔵 LOGO
                  const Icon(
                    Icons.psychology,
                    size: 60,
                    color: Color(0xFF6C63FF),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _isSignUp ? "Créer un compte" : "Bon retour 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _isSignUp
                        ? "Rejoins DevCare"
                        : "Connecte-toi pour continuer",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // 👤 NOM + PRÉNOM (SIGN UP)
                  if (_isSignUp) ...[
                    _input(_firstNameController, "Prénom", Icons.person),
                    const SizedBox(height: 10),
                    _input(_lastNameController, "Nom", Icons.person_outline),
                    const SizedBox(height: 10),
                  ],

                  // 📧 EMAIL
                  _input(_emailController, "Email", Icons.email),

                  const SizedBox(height: 10),

                  // 🔒 PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    // 🔐 PASSWORD SECURE
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Mot de passe requis";
                      }
                      if (v.length < 8) {
                        return "Minimum 8 caractères";
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(v)) {
                        return "Ajouter une majuscule";
                      }
                      if (!RegExp(r'[0-9]').hasMatch(v)) {
                        return "Ajouter un chiffre";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 🚀 BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              _isSignUp
                                  ? "Créer compte"
                                  : "Se connecter",
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔁 SWITCH LOGIN / SIGNUP
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? "Déjà un compte ? Se connecter"
                          : "Créer un compte",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 INPUT WIDGET
  Widget _input(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? "Champ requis" : null,
    );
  }
}