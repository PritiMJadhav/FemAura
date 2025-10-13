import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puzzle_game.dart';
import '../main_menu.dart'; // import MainMenu

class PuzzleHomeScreen extends StatefulWidget {
  const PuzzleHomeScreen({super.key});

  @override
  State<PuzzleHomeScreen> createState() => _PuzzleHomeScreenState();
}

class _PuzzleHomeScreenState extends State<PuzzleHomeScreen> {
  late SharedPreferences prefs;
  Map<String, Set<String>> solvedPuzzles = {
    "easy": {},
    "medium": {},
    "hard": {},
  };

  final Map<String, List<String>> puzzleImages = {
    "easy": [
      "assets/puzzle_game/images/easy/easy1.png",
      "assets/puzzle_game/images/easy/easy2.png",
      "assets/puzzle_game/images/easy/easy3.png",
      "assets/puzzle_game/images/easy/easy4.png",
    ],
    "medium": [
      "assets/puzzle_game/images/medium/medium1.jpg",
      "assets/puzzle_game/images/medium/medium2.jpg",
      "assets/puzzle_game/images/medium/medium3.jpg",
      "assets/puzzle_game/images/medium/medium4.jpg",
    ],
    "hard": [
      "assets/puzzle_game/images/hard/hard1.jpg",
      "assets/puzzle_game/images/hard/hard2.jpg",
      "assets/puzzle_game/images/hard/hard3.jpg",
      "assets/puzzle_game/images/hard/hard4.jpg",
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSolvedPuzzles();
  }

  Future<void> _loadSolvedPuzzles() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      solvedPuzzles["easy"] = prefs.getStringList("easy")?.toSet() ?? {};
      solvedPuzzles["medium"] = prefs.getStringList("medium")?.toSet() ?? {};
      solvedPuzzles["hard"] = prefs.getStringList("hard")?.toSet() ?? {};
    });
  }

  void _startGame(String difficulty, int gridSize) {
    final allImages = puzzleImages[difficulty]!;
    final unsolvedImages = allImages
        .where((img) => !solvedPuzzles[difficulty]!.contains(img))
        .toList();

    if (unsolvedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All puzzles completed for $difficulty!")),
      );
      return;
    }

    final selectedImage =
        unsolvedImages[Random().nextInt(unsolvedImages.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          gridSize: gridSize,
          difficulty: difficulty,
          imagePath: selectedImage,
          onSolved: () async {
            await _loadSolvedPuzzles();
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _puzzleCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'PlayfairDisplay',
                )),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDFDF), Color(0xFFFA96A8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const MainMenu()));
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Header
                Column(
                  children: const [
                    Text(
                      "🧩 Self-Care Puzzle",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'PlayfairDisplay'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pick a difficulty and challenge yourself with relaxing puzzles.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Scrollable Cards
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _puzzleCard(
                          title:
                              "🌱 Easy (3x3) - ${solvedPuzzles["easy"]?.length ?? 0}/${puzzleImages["easy"]!.length}",
                          subtitle: "Beginner-friendly relaxing puzzle",
                          gradientColors: [
                            Color(0xFFB86A87),
                            Color(0xFF9C3B5B)
                          ],
                          onTap: () => _startGame("easy", 3),
                        ),
                        _puzzleCard(
                          title:
                              "🌿 Medium (4x4) - ${solvedPuzzles["medium"]?.length ?? 0}/${puzzleImages["medium"]!.length}",
                          subtitle: "Moderate challenge for focused mind",
                          gradientColors: [
                            Color(0xFFC6B8DC),
                            Color(0xFF8678B2)
                          ],
                          onTap: () => _startGame("medium", 4),
                        ),
                        _puzzleCard(
                          title:
                              "🌸 Hard (5x5) - ${solvedPuzzles["hard"]?.length ?? 0}/${puzzleImages["hard"]!.length}",
                          subtitle: "Expert-level puzzle for concentration",
                          gradientColors: [
                            Color(0xFFE577C0),
                            Color(0xFFB61C9B)
                          ],
                          onTap: () => _startGame("hard", 5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "🧩 Relax, have fun & enjoy your self-care puzzle journey!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
