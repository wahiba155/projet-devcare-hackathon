import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/stuck_provider.dart';
import 'login_screen.dart';
import 'breathing_screen.dart';
import 'relaxation_screen.dart';
import 'stress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération de l'auth pour le pseudo et la déconnexion
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'DevCare 💙',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Se déconnecter'),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bonjour 👋", // Ou authProvider.userDisplayName si disponible
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- BANDEAU ÉTAT MENTAL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                "🧠 Votre état mental actuel semble : Stress Moyen",
                style: TextStyle(fontSize: 15, color: Colors.deepOrange, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Analyse & Assistance IA",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- CARTE AGENT IA STRESS ---
            _buildSectionCard(
              context,
              title: "Agent IA Stress",
              subtitle: "Analysez votre état mental en temps réel",
              icon: Icons.psychology,
              color: Colors.indigo.shade50,
              iconColor: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StressScreen()),
              ),
            ),

            const SizedBox(height: 12),

            // --- CARTE STUCK BREAKER (MANUEL) ---
            _buildSectionCard(
              context,
              title: "Stuck Breaker",
              subtitle: "Je suis bloqué, aide-moi !",
              icon: Icons.psychology_alt,
              color: const Color(0xFFF3F2FF),
              iconColor: const Color(0xFF6C63FF),
              onTap: () {
                // Déclenche l'IA avec un score par défaut
                context.read<StuckProvider>().triggerStuckState(60);
              },
            ),

            const SizedBox(height: 32),
            const Text(
              "Micro-actions recommandées",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- ACTIONS RAPIDES (Respiration / Relaxation) ---
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: "Respiration",
                    icon: Icons.air,
                    color: Colors.lightBlue.shade100,
                    iconColor: Colors.lightBlue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BreathingScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: "Relaxation",
                    icon: Icons.headphones,
                    color: Colors.purple.shade100,
                    iconColor: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RelaxationScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les grandes cartes horizontales
  Widget _buildSectionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: iconColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }

  // Widget pour les petites cartes carrées
  Widget _buildActionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}