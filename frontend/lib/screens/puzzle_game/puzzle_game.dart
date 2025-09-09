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

  String currentImagePath = ""; // Current puzzle image
  List<List<int>> moveHistory = []; // Undo history

  // Confetti
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
      pieceOrder = List.generate(widget.gridSize * widget.gridSize, (i) => i)..shuffle();
      moveHistory.clear();
    });
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void _playBackgroundMusic() async {
    await bgPlayer.setReleaseMode(ReleaseMode.loop);
    if (bgSoundOn) {
      await bgPlayer.play(AssetSource("puzzle_game/sounds/loop.mp3"), volume: 0.5);
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
    // Save current order for undo
    moveHistory.add(List.from(pieceOrder));

    setState(() {
      final fromIndex = pieceOrder.indexOf(pieceIndex);
      pieceOrder[fromIndex] = pieceOrder[targetIndex];
      pieceOrder[targetIndex] = pieceIndex;
      moves++;
    });

    if (clickSoundOn) {
      await swapPlayer.play(AssetSource("puzzle_game/sounds/click.mp3"), volume: 1.0);
    }

    if (_isPuzzleSolved()) _showWinDialog();
  }

  bool _isPuzzleSolved() => pieceOrder.asMap().entries.every((e) => e.key == e.value);

  void _undoMove() {
    if (moveHistory.isEmpty) return;
    setState(() {
      pieceOrder = moveHistory.removeLast();
      moves = max(0, moves - 1);
    });
  }

  void _showHint() {
    // Show one correct piece temporarily
    final incorrectIndices = List<int>.generate(pieceOrder.length, (i) => i)
        .where((i) => pieceOrder[i] != i)
        .toList();
    if (incorrectIndices.isEmpty) return;

    final hintIndex = incorrectIndices[Random().nextInt(incorrectIndices.length)];
    final originalPiece = pieceOrder[hintIndex];

    setState(() {
      pieceOrder[hintIndex] = hintIndex; // Correct position temporarily
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        pieceOrder[hintIndex] = originalPiece; // Revert to previous
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
        title: const Text("🎉 Puzzle Completed!", style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text("Moves: $moves\nTime: $seconds s", style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          _hoverButton("Back to Home", () {
            Navigator.pop(context);
            Navigator.pop(context);
          }),
          _hoverButton("Restart", () {
            Navigator.pop(context);
            _restartPuzzle();
          }),
          _hoverButton("Next Puzzle", () {
            Navigator.pop(context);
            _loadNextPuzzle();
          }),
        ],
      ),
    );
  }

  Widget _hoverButton(String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  void _restartPuzzle() {
    setState(() {
      pieceOrder.shuffle(Random());
      moves = 0;
      seconds = 0;
      moveHistory.clear();
    });
    timer?.cancel();
    _startTimer();
  }

  Future<void> _loadNextPuzzle() async {
    final allImages = puzzleImages[widget.difficulty]!;
    final unsolvedImages = allImages.where((img) => !solvedPuzzles.contains(img)).toList();

    if (unsolvedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All puzzles completed for this difficulty!")),
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
    if (!imageLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double pieceWidth = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) / widget.gridSize;
    double pieceHeight = pieceWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Self-Care Puzzle"),
        backgroundColor: Colors.blue.shade200,
        actions: [
          IconButton(
            icon: Icon(showTarget ? Icons.visibility : Icons.visibility_off),
            tooltip: showTarget ? "Hide Target" : "Show Target",
            onPressed: () => setState(() => showTarget = !showTarget),
          ),
          IconButton(
            icon: Icon(bgSoundOn ? Icons.volume_up : Icons.volume_off),
            tooltip: "Background Music",
            onPressed: _toggleBGMusic,
          ),
          IconButton(
            icon: Icon(clickSoundOn ? Icons.music_note : Icons.music_off),
            tooltip: "Piece Sound",
            onPressed: _toggleClickSound,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Restart Puzzle",
            onPressed: _restartPuzzle,
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            tooltip: "Hint",
            onPressed: _showHint,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: "Undo",
            onPressed: _undoMove,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (showTarget)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(currentImagePath, height: 100, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Target Image",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _getProgress(),
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "🧩 Moves: $moves   ⏱ Time: $seconds s",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.gridSize),
                  itemCount: pieceOrder.length,
                  itemBuilder: (context, targetIndex) {
                    int pieceIndex = pieceOrder[targetIndex];
                    int row = pieceIndex ~/ widget.gridSize;
                    int col = pieceIndex % widget.gridSize;

                    return DragTarget<int>(
                      onAccept: (draggedPiece) => _onPieceDropped(draggedPiece, targetIndex),
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
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.blue.shade300,
        child: const Icon(Icons.arrow_back),
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
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRect(dst, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
