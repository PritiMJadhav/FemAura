// NO changes in import section
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class BubbleGameScreen extends StatefulWidget {
  const BubbleGameScreen({super.key});

  @override
  State<BubbleGameScreen> createState() => _BubbleGameScreenState();
}

class _BubbleGameScreenState extends State<BubbleGameScreen>
    with TickerProviderStateMixin {
  List<String> thoughts = [
    'stress',
    'tired',
    'overthinking',
    'sad',
    'mood swings',
    'self doubt',
    'anxiety',
    'fear',
    'comparison',
    'regret',
    'doubt',
    'hopelessness',
  ];

  List<String> tapped = [];
  int score = 0;
  bool isGameOver = false;
  bool isPaused = false;
  bool isMuted = false;

  late Timer timer;
  int timeLeft = 30;

  final AudioPlayer player = AudioPlayer();
  final AudioPlayer bgPlayer = AudioPlayer(); // replaced AssetsAudioPlayer
  final List<String> quotes = [
    "You're stronger than you think.",
    "Peace begins with a single breath.",
    "You’re doing amazing 🌟",
    "Let go. Just be.",
    "Your calm is powerful."
  ];

  late List<String> distractionWords;
  final List<BubbleWidgetState> bubbleStates = [];

  @override
  void initState() {
    super.initState();
    assignDistractions();
    startTimer();
    playBackgroundMusic();
  }

  void assignDistractions() {
    final random = Random();
    distractionWords = [];
    while (distractionWords.length < 5) {
      String word = thoughts[random.nextInt(thoughts.length)];
      if (!distractionWords.contains(word)) {
        distractionWords.add(word);
      }
    }
  }

  void playBackgroundMusic() async {
    await bgPlayer.setReleaseMode(ReleaseMode.loop);
    await bgPlayer.setVolume(isMuted ? 0 : 0.4);
    await bgPlayer.play(AssetSource('bubble_game/sounds/calm_bg.mp3'));
  }

  void stopBackgroundMusic() {
    bgPlayer.stop();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isPaused) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            t.cancel();
            isGameOver = true;
            stopBackgroundMusic();
          }
        });
      }
    });
  }

  void pauseGame() {
    setState(() {
      isPaused = true;
      bgPlayer.pause();
      for (var b in bubbleStates) {
        b.pauseBubble();
      }
      showPauseMenu();
    });
  }

  void resumeGame() {
    setState(() {
      isPaused = false;
      bgPlayer.resume();
      for (var b in bubbleStates) {
        b.resumeBubble();
      }
    });
  }

  void resetGame() {
    timer.cancel();
    bgPlayer.stop();
    setState(() {
      tapped.clear();
      score = 0;
      isGameOver = false;
      timeLeft = 30;
      isPaused = false;
      assignDistractions();
      startTimer();
      playBackgroundMusic();
      for (var b in bubbleStates) {
        b.resetBubble();
      }
    });
  }

  void showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text(
          '⏸ Paused',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        content: const Text(
          'Take a break, relax, and then continue your game.\n\n'
          'Press "Resume" to continue or "Restart" to start fresh.',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              if (mounted) resetGame(); // safe call
            },
            child: const Text(
              'Restart',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) resumeGame();
            },
            child: const Text(
              'Resume',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleSound() {
    setState(() {
      isMuted = !isMuted;
      bgPlayer.setVolume(isMuted ? 0 : 0.4);
    });
  }

  void onTapBubble(String word) async {
    const int thoughtPoints = 10;
    const int distractionPenalty = 5;

    if (distractionWords.contains(word)) {
      setState(() {
        score = max(0, score - distractionPenalty);
      });

      // Instead of canceling, just pause
      isPaused = true;
      bgPlayer.pause();
      timer.cancel(); // <- optional, but you can restart later

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.purple.shade50,
          title: const Text("🌀 Distraction!"),
          content: const Text(
            "Oops! That was a distraction bubble.\nYou lost 5 points.\nBreathe & try again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame(); // restarts timer + music cleanly
              },
              child: const Text("Play Again"),
            )
          ],
        ),
      );
      return;
    }

    setState(() {
      tapped.add(word); // bubble disappears
      score += thoughtPoints;

      if (tapped.length == thoughts.length - distractionWords.length) {
        timer.cancel();
        isGameOver = true;
        stopBackgroundMusic();
      }
    });

    player.play(AssetSource('bubble_game/sounds/tap.mp3'));
  }

  @override
  void dispose() {
    player.dispose();
    bgPlayer.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bubble_game/images/game_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isGameOver ? buildGameOverScreen() : buildGameUI(),
          ),
        ],
      ),
    );
  }

// --- rest of your game UI code unchanged ---
// --- BubbleWidget and buildGameUI/buildGameOverScreen remain the same ---

  Widget buildGameUI() {
    return Stack(
      children: [
        ...thoughts.map((word) {
          final isTapped = tapped.contains(word);
          return BubbleWidget(
            word: word,
            onTap: () => onTapBubble(word),
            isDistraction: distractionWords.contains(word),
            registerState: (state) => bubbleStates.add(state),
            isVisible: !isTapped,
          );
        }).toList(),

        // Top Bar
        // Top Bar with bold text & icons, no background box
// Top Bar with softer bold & colored icons
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button in dark pink
                IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: Colors.pink[800], size: 28),
                  onPressed: () {
                    timer.cancel();
                    stopBackgroundMusic();
                    Navigator.pop(context);
                  },
                ),

                // Timer & Score
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🕒 $timeLeft sec",
                      style: TextStyle(
                        color: Colors.pink[900],
                        fontWeight: FontWeight.w600, // slightly less bold
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "🎯 $score",
                      style: TextStyle(
                        color: Colors.pink[900],
                        fontWeight: FontWeight.w600, // slightly less bold
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Sound & Pause buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.pink[800],
                        size: 28,
                      ),
                      onPressed: toggleSound,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.pause_circle,
                          color: Colors.pink[800], size: 30),
                      onPressed: pauseGame,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Reset button
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 204, 204),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "Reset",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGameOverScreen() {
    String randomQuote = quotes[DateTime.now().second % quotes.length];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "🎉 Great Job!",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 12),
          Text("You cleared ${tapped.length} thoughts.",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(179, 0, 0, 0))),
          const SizedBox(height: 20),
          Text(randomQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(179, 0, 0, 0))),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Play Again",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// Bubble Widget
class BubbleWidget extends StatefulWidget {
  final String word;
  final VoidCallback onTap;
  final bool isDistraction;
  final Function(BubbleWidgetState)? registerState;
  final bool isVisible;

  const BubbleWidget({
    super.key,
    required this.word,
    required this.onTap,
    this.isDistraction = false,
    this.registerState,
    this.isVisible = true,
  });

  @override
  BubbleWidgetState createState() => BubbleWidgetState();
}

class BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double top;
  late double left;
  late double dx;
  late double dy;
  final Random random = Random();
  late double bubbleSize;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(hours: 1))
          ..addListener(updatePosition)
          ..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;

      bubbleSize = widget.isDistraction ? 100 : 90;
      top = random.nextDouble() * (screenSize.height - bubbleSize - 100);
      left = random.nextDouble() * (screenSize.width - bubbleSize);

      const double minSpeed = 0.8;
      const double maxSpeed = 1.8;

      dx = (random.nextDouble() * (maxSpeed - minSpeed) + minSpeed) *
          (random.nextBool() ? 1 : -1);
      dy = (random.nextDouble() * (maxSpeed - minSpeed) + minSpeed) *
          (random.nextBool() ? 1 : -1);

      widget.registerState?.call(this);
    });
  }

  void updatePosition() {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      left += dx;
      top += dy;

      if (left <= 0 || left >= screenSize.width - bubbleSize) dx = -dx;
      if (top <= 0 || top >= screenSize.height - bubbleSize - 100) dy = -dy;
    });
  }

  void pauseBubble() => _controller.stop();
  void resumeBubble() => _controller.forward();
  void resetBubble() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: AnimatedOpacity(
          opacity: widget.isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: bubbleSize,
              height: bubbleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDistraction
                    ? Colors.purple.shade100.withOpacity(0.8)
                    : Colors.pink.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: widget.isVisible
                  ? Text(
                      widget.isDistraction ? '🌀' : widget.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.isDistraction ? 30 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
