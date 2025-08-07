import 'package:flutter/material.dart';
import 'package:frontend/period_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(FemAuraApp());
}

class FemAuraApp extends StatelessWidget {
  const FemAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FemAura',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/homepage' : (context) => HomeScreen(),
        '/period_tracker': (context) => PeriodTrackerPage()
      },
    );
  }
}
