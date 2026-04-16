import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as app_auth; // 👈 alias anti-conflit
import '../providers/stuck_provider.dart';
import 'login_screen.dart';
import 'breathing_screen.dart';
import 'relaxation_screen.dart';
import 'stress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>> _fetchUserStats(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("stress_log")
        .where("uid", isEqualTo: uid)
        .orderBy("timestamp", descending: true)
        .limit(10)
        .get();

    final docs = snapshot.docs.map((d) => d.data()).toList();

    if (docs.isEmpty) return {"average": "0", "lastState": "—", "count": 0};

    final avgScore =
        docs.map((d) => (d["score"] as num).toDouble()).reduce((a, b) => a + b) /
            docs.length;
    final lastState = docs.first["state"] ?? "—";

    return {
      "average": avgScore.toStringAsFixed(0),
      "lastState": lastState,
      "count": docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<app_auth.AuthProvider>(); // 👈 alias
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

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
            icon: const CircleAvatar(child: Icon(Icons.person)),
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
              "Bonjour 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- BANDEAU ÉTAT MENTAL DYNAMIQUE ---
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserStats(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      "⚠️ Impossible de charger les stats",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final stats = snapshot.data!;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🧠 Score moyen : ${stats['average']} / 100",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "📊 Dernier état : ${stats['lastState']}  •  ${stats['count']} sessions",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              "Analyse & Assistance IA",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

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

            _buildSectionCard(
              context,
              title: "Stuck Breaker",
              subtitle: "Je suis bloqué, aide-moi !",
              icon: Icons.psychology_alt,
              color: const Color(0xFFF3F2FF),
              iconColor: const Color(0xFF6C63FF),
              onTap: () {
                context.read<StuckProvider>().triggerStuckState(60);
              },
            ),

            const SizedBox(height: 32),
            const Text(
              "Micro-actions recommandées",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

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
                      MaterialPageRoute(
                          builder: (_) => const RelaxationScreen()),
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