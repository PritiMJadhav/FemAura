import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile.dart';
import 'hydration_reminder_page.dart';

void main() {
  runApp(const FemAuraApp());
}

class FemAuraApp extends StatelessWidget {
  const FemAuraApp({super.key});

  const FemAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FemAura',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profile': (context) => const ProfilePage(),
        '/hydration': (context) => const HydrationReminderPage(),
      },
    );
  }
}
