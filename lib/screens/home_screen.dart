import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('DevCare'),
        actions: [
          PopupMenuButton(
            icon: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Se déconnecter'),
                value: 'logout',
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await user.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenue 🎉'),
      ),
    );
  }
}