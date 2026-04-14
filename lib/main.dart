import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wellness_provider.dart';
import 'screens/login_screen.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: 'DevCare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}