import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puzzle_game.dart';

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
    final unsolvedImages =
        allImages.where((img) => !solvedPuzzles[difficulty]!.contains(img)).toList();

    if (unsolvedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All puzzles completed for $difficulty!")),
      );
      return;
    }

    final selectedImage = unsolvedImages[Random().nextInt(unsolvedImages.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          gridSize: gridSize,
          difficulty: difficulty,
          imagePath: selectedImage,
          onSolved: () async {
            await _loadSolvedPuzzles();
            setState(() {}); // Refresh progress
          },
        ),
      ),
    );
  }

  Widget _difficultyButton(String text, Color bgColor, String difficulty, int gridSize) {
    return _hoverButton(text, () => _startGame(difficulty, gridSize), bgColor);
  }

  Widget _hoverButton(String text, VoidCallback onTap, Color bgColor) {
    return StatefulBuilder(
      builder: (context, setHoverState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setHoverState(() => isHovered = true),
          onExit: (_) => setHoverState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedScale(
              scale: isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        centerTitle: true,
        title: const Text(
          "Self-Care Puzzle",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, size: 70, color: Colors.blue),
            const SizedBox(height: 15),
            const Text(
              "🧩 Welcome to the Self-Care Puzzle!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pick a difficulty level and test your skills by completing a relaxing puzzle.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 30),
            _difficultyButton(
              "🌱 Easy (3x3) - ${solvedPuzzles["easy"]?.length ?? 0}/${puzzleImages["easy"]!.length}",
              Colors.green.shade400,
              "easy",
              3,
            ),
            _difficultyButton(
              "🌿 Medium (4x4) - ${solvedPuzzles["medium"]?.length ?? 0}/${puzzleImages["medium"]!.length}",
              Colors.orange.shade400,
              "medium",
              4,
            ),
            _difficultyButton(
              "🌸 Hard (5x5) - ${solvedPuzzles["hard"]?.length ?? 0}/${puzzleImages["hard"]!.length}",
              Colors.red.shade400,
              "hard",
              5,
            ),
          ],
        ),
      ),
    );
  }
}
