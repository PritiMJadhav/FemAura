import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bubble_game/home_screen.dart';
import 'puzzle_game/puzzle_home.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const _GlassTitle(),
      ),
      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/common/menu_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // overlay for clarity
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.10), // slightly darker
                    Colors.black.withOpacity(0.28),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const _Tagline(),
                      const SizedBox(height: 20),

                      _GameCard(
                        title: 'Bubble Pop',
                        subtitle: 'Tap thoughts, avoid the swirl!',
                        imagePath: 'assets/common/bubble_icon.png',
                        gradient: const [Color(0xffFFDCE6), Color(0xffFFCCE0)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _GameCard(
                        title: 'Self-Care Puzzle',
                        subtitle: 'Cozy snaps that calm the mind',
                        imagePath: 'assets/common/puzzle_icon.png',
                        gradient: const [Color(0xffD8F5FF), Color(0xffCDEFFF)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PuzzleHomeScreen()),
                          );
                        },
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          'Calm Zone • ${size.width.toInt()}×${size.height.toInt()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassTitle extends StatelessWidget {
  const _GlassTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: const Text(
        'Game Zone 🎮',
        style: TextStyle(
          fontWeight: FontWeight.w900, // boldest
          color: Colors.black87,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Relax & Play',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 4),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Two gentle mini-games to reset your mind.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
            shadows: [
              Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  double _scale = 1.0;
  bool _hover = false;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.97 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(widget.imagePath, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3)],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 140, 140).withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Text(
                'Play',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 7, 7, 7),
                  shadows: [Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (e) {
        if (kIsWeb ||
            Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.macOS ||
            Theme.of(context).platform == TargetPlatform.linux) {
          setState(() {
            _hover = true;
            _setPressed(true);
          });
        }
      },
      onExit: (e) {
        if (_hover) {
          setState(() {
            _hover = false;
            _setPressed(false);
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onTap,
        child: child,
      ),
    );
  }
}
