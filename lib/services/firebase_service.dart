import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get userId => _auth.currentUser?.uid;

  // Authentification anonyme (rapide pour hackathon)
  static Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Sauvegarder une entrée de stress
  static Future<void> saveStressEntry({
    required int score,
    required String state,
    required String action,
  }) async {
    if (userId == null) await signInAnonymously();

    await _db
        .collection('users')
        .doc(userId)
        .collection('stress_entries')
        .add({
      'score': score,
      'state': state,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer l'historique des 7 derniers jours
  static Future<List<Map<String, dynamic>>> getWeekHistory() async {
    if (userId == null) return [];

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('stress_entries')
        .where('timestamp', isGreaterThan: sevenDaysAgo)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}