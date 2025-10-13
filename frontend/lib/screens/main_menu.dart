import 'package:flutter/material.dart';
import 'bubble_game/home_screen.dart';
import 'puzzle_game/puzzle_home.dart';
import 'package:frontend/profile.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDFDF), Color(0xFFFA96A8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    Image.asset('assets/logo.png', height: 40),
                    const Icon(Icons.notifications_outlined,
                        color: Color(0xFFD10C6A)),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Relax & Play 🎮',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Two gentle mini-games to reset your mind',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Bubble Pop Game Card
                _gameCard(
                  title: 'Bubble Pop',
                  subtitle: 'Tap thoughts, avoid the swirl!',
                  gradientColors: [Color(0xFFE49E84), Color(0xFFBF5740)],
                  buttonColor: const Color(0xFFBF5740),
                  buttonText: 'Play Now',
                  iconPath: 'assets/common/bubble_icon.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),

                // Puzzle Game Card
                _gameCard(
                  title: 'Self-Care Puzzle',
                  subtitle: 'Cozy snaps that calm the mind',
                  gradientColors: [Color(0xFFE577C0), Color(0xFFB61C9B)],
                  buttonColor: const Color(0xFFB61C9B),
                  buttonText: 'Play Now',
                  iconPath: 'assets/common/puzzle_icon.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PuzzleHomeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color buttonColor,
    required String buttonText,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon/Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              iconPath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Text & Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
