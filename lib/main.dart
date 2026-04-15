import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import des providers
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wellness_provider.dart';
import 'providers/stuck_provider.dart';

// Import des écrans
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/stuck_screen.dart';

void main() async {
  // Initialisation obligatoire pour Firebase et les bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DevCareApp());
}

class DevCareApp extends StatelessWidget {
  const DevCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WellnessProvider()),
        // On initialise le StuckProvider et on lance le timer d'inactivité immédiatement
        ChangeNotifierProvider(create: (_) => StuckProvider()..resetInactivityTimer()),
      ],
      child: Builder(
        builder: (context) {
          return Listener(
            // Ce widget détecte les interactions sur toute l'app pour réinitialiser le timer
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              context.read<StuckProvider>().resetInactivityTimer();
            },
            child: MaterialApp(
              title: 'DevCare',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
                useMaterial3: true,
                fontFamily: 'Roboto',
              ),
              debugShowCheckedModeBanner: false,
              // Logique de routage dynamique
              home: _RootNavigation(),
            ),
          );
        },
      ),
    );
  }
}

/// Widget interne pour gérer le flux : Auth -> Stuck Detection -> Home
class _RootNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final stuckProvider = context.watch<StuckProvider>();

    // 1. Si l'utilisateur n'est pas connecté, direction Login
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // 2. Si l'utilisateur est connecté mais "bloqué" (inactivité ou stress), direction StuckScreen
    if (stuckProvider.isStuck) {
      return const StuckScreen();
    }

    // 3. Sinon, on affiche l'écran d'accueil normal
    return const HomeScreen();
  }
}