import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class PuzzleGameScreen extends StatefulWidget {
  final int gridSize;
  final String difficulty;
  final String imagePath;
  final VoidCallback onSolved;

  const PuzzleGameScreen({
    super.key,
    required this.gridSize,
    required this.difficulty,
    required this.imagePath,
    required this.onSolved,
  });

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late ui.Image image;
  bool imageLoaded = false;

  List<int> pieceOrder = [];
  int moves = 0;
  int seconds = 0;
  Timer? timer;

  bool showTarget = true;
  bool bgSoundOn = true;
  bool clickSoundOn = true;

  late SharedPreferences prefs;
  Set<String> solvedPuzzles = {};

  final AudioPlayer swapPlayer = AudioPlayer();
  final AudioPlayer bgPlayer = AudioPlayer();

  String currentImagePath = "";
  List<List<int>> moveHistory = [];

  late ConfettiController _confettiController;

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
    _initPrefs();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadImage(widget.imagePath);
    _startTimer();
    _playBackgroundMusic();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    solvedPuzzles = prefs.getStringList(widget.difficulty)?.toSet() ?? {};
  }

  Future<void> _loadImage(String path) async {
    currentImagePath = path;
    final completer = Completer<ui.Image>();
    final imageStream = AssetImage(path).resolve(const ImageConfiguration());
    imageStream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }));
    image = await completer.future;

    setState(() {
      imageLoaded = true;
      pieceOrder = List.generate(widget.gridSize * widget.gridSize, (i) => i)
        ..shuffle();
      moveHistory.clear();
    });
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  void _playBackgroundMusic() async {
    await bgPlayer.setReleaseMode(ReleaseMode.loop);
    if (bgSoundOn) {
      await bgPlayer.play(AssetSource("puzzle_game/sounds/loop.mp3"),
          volume: 0.5);
    }
  }

  void _toggleBGMusic() {
    setState(() {
      bgSoundOn = !bgSoundOn;
      if (bgSoundOn) {
        _playBackgroundMusic();
      } else {
        bgPlayer.pause();
      }
    });
  }

  void _toggleClickSound() {
    setState(() => clickSoundOn = !clickSoundOn);
  }

  void _onPieceDropped(int pieceIndex, int targetIndex) async {
    moveHistory.add(List.from(pieceOrder));
    setState(() {
      final fromIndex = pieceOrder.indexOf(pieceIndex);
      pieceOrder[fromIndex] = pieceOrder[targetIndex];
      pieceOrder[targetIndex] = pieceIndex;
      moves++;
    });
    if (clickSoundOn) {
      await swapPlayer.play(AssetSource("puzzle_game/sounds/click.mp3"),
          volume: 1.0);
    }
    if (_isPuzzleSolved()) _showWinDialog();
  }

  bool _isPuzzleSolved() =>
      pieceOrder.asMap().entries.every((e) => e.key == e.value);

  void _undoMove() {
    if (moveHistory.isEmpty) return;
    setState(() {
      pieceOrder = moveHistory.removeLast();
      moves = max(0, moves - 1);
    });
  }

  void _showHint() {
    final incorrectIndices = List<int>.generate(pieceOrder.length, (i) => i)
        .where((i) => pieceOrder[i] != i)
        .toList();
    if (incorrectIndices.isEmpty) return;

    final hintIndex =
        incorrectIndices[Random().nextInt(incorrectIndices.length)];
    final originalPiece = pieceOrder[hintIndex];

    setState(() {
      pieceOrder[hintIndex] = hintIndex;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        if (!_isPuzzleSolved()) pieceOrder[hintIndex] = originalPiece;
      });
    });
  }

  void _showWinDialog() {
    timer?.cancel();
    solvedPuzzles.add(currentImagePath);
    prefs.setStringList(widget.difficulty, solvedPuzzles.toList());
    widget.onSolved();
    _confettiController.play();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        title: const Text("🎉 Puzzle Completed!",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text("Moves: $moves\nTime: $seconds s",
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          _styledAction("Back to Home", () {
            Navigator.pop(context);
            Navigator.pop(context);
          }),
          _styledAction("Restart", () {
            Navigator.pop(context);
            _restartPuzzle();
          }),
          _styledAction("Next Puzzle", () {
            Navigator.pop(context);
            _loadNextPuzzle();
          }),
        ],
      ),
    );
  }

  Widget _styledAction(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  void _restartPuzzle() {
    setState(() {
      pieceOrder.shuffle(Random());
      moves = 0;
      seconds = 0;
      moveHistory.clear();
    });
    _startTimer();
  }

  Future<void> _loadNextPuzzle() async {
    final allImages = puzzleImages[widget.difficulty]!;
    final unsolvedImages =
        allImages.where((img) => !solvedPuzzles.contains(img)).toList();

    if (unsolvedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("All puzzles completed for this difficulty!")),
      );
      return;
    }

    final newImage = unsolvedImages[Random().nextInt(unsolvedImages.length)];
    setState(() {
      imageLoaded = false;
      moves = 0;
      seconds = 0;
      moveHistory.clear();
    });

    await _loadImage(newImage);
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    bgPlayer.dispose();
    swapPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!imageLoaded)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.padding.top - 220;
    double pieceWidth = min(
        media.size.width / widget.gridSize, availableHeight / widget.gridSize);
    double pieceHeight = pieceWidth;

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
          child: Column(
            children: [
              // Top bar
              _buildTopBar(),

              // Controls
              _buildControls(),

              // Target Preview
              if (showTarget) _buildTargetPreview(),

              // Progress
              _buildProgress(),

              const SizedBox(height: 8),

              // Puzzle Grid
              Expanded(child: _buildPuzzleGrid(pieceWidth, pieceHeight)),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Positioned(
            bottom: 86,
            right: 16,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "🧩 Self-Care Puzzle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Difficulty: ${widget.difficulty}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 6),
              Text("Moves: $moves  •  ${seconds}s",
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _roundedControl(
              icon: showTarget ? Icons.visibility : Icons.visibility_off,
              label: showTarget ? "Hide" : "Preview",
              onTap: () => setState(() => showTarget = !showTarget),
              gradient: const [Color(0xFFE577C0), Color(0xFFB61C9B)]),
          _roundedControl(
              icon: bgSoundOn ? Icons.volume_up : Icons.volume_off,
              label: "Music",
              onTap: _toggleBGMusic,
              gradient: const [Color(0xFFE49E84), Color(0xFFBF5740)]),
          _roundedControl(
              icon: clickSoundOn ? Icons.music_note : Icons.music_off,
              label: "Piece",
              onTap: _toggleClickSound,
              gradient: const [Color(0xFFC6B8DC), Color(0xFF8678B2)]),
          _roundedControl(
              icon: Icons.refresh,
              label: "Restart",
              onTap: _restartPuzzle,
              gradient: const [Color(0xFFB86A87), Color(0xFF9C3B5B)]),
          _roundedControl(
              icon: Icons.lightbulb,
              label: "Hint",
              onTap: _showHint,
              gradient: const [Color(0xFFB1BFF4), Color(0xFF969CED)]),
          _roundedControl(
              icon: Icons.undo,
              label: "Undo",
              onTap: _undoMove,
              gradient: const [Color(0xFFAED1AF), Color(0xFF82BC85)]),
        ],
      ),
    );
  }

  Widget _buildTargetPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  Image.asset(currentImagePath, height: 110, fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            const Text("Target Image",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _getProgress(),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 8),
          Text(
              "Progress: ${(100 * _getProgress()).toStringAsFixed(0)}% • Moves: $moves • Time: ${seconds}s",
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPuzzleGrid(double pieceWidth, double pieceHeight) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            childAspectRatio: pieceWidth / pieceHeight,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: pieceOrder.length,
          shrinkWrap: true,
          itemBuilder: (context, targetIndex) {
            int pieceIndex = pieceOrder[targetIndex];
            int row = pieceIndex ~/ widget.gridSize;
            int col = pieceIndex % widget.gridSize;

            return DragTarget<int>(
              onAccept: (draggedPiece) =>
                  _onPieceDropped(draggedPiece, targetIndex),
              builder: (context, candidateData, rejectedData) {
                return Draggable<int>(
                  data: pieceIndex,
                  feedback: SizedBox(
                    width: pieceWidth,
                    height: pieceHeight,
                    child: CustomPaint(
                      painter: PuzzlePiecePainter(
                        image: image,
                        row: row,
                        col: col,
                        gridSize: widget.gridSize,
                        pieceWidth: pieceWidth,
                        pieceHeight: pieceHeight,
                      ),
                    ),
                  ),
                  childWhenDragging: Container(color: Colors.grey[200]),
                  child: CustomPaint(
                    painter: PuzzlePiecePainter(
                      image: image,
                      row: row,
                      col: col,
                      gridSize: widget.gridSize,
                      pieceWidth: pieceWidth,
                      pieceHeight: pieceHeight,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _roundedControl({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  double _getProgress() {
    int correct = 0;
    for (int i = 0; i < pieceOrder.length; i++) {
      if (pieceOrder[i] == i) correct++;
    }
    return correct / pieceOrder.length;
  }
}

class PuzzlePiecePainter extends CustomPainter {
  final ui.Image image;
  final int row;
  final int col;
  final int gridSize;
  final double pieceWidth;
  final double pieceHeight;

  PuzzlePiecePainter({
    required this.image,
    required this.row,
    required this.col,
    required this.gridSize,
    required this.pieceWidth,
    required this.pieceHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final src = Rect.fromLTWH(
      col * (image.width / gridSize),
      row * (image.height / gridSize),
      image.width / gridSize,
      image.height / gridSize,
    );
    final dst = Rect.fromLTWH(0, 0, pieceWidth, pieceHeight);
    canvas.drawImageRect(image, src, dst, paint);

    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(dst, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
