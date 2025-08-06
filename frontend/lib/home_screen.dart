import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final List<String> _images = [
    'assets/slide1.png',
    'assets/slide2.png',
    'assets/slide3.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentIndex < _images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (mounted) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDFDF), Color.fromARGB(255, 250, 150, 168)],
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
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    Image.asset('assets/logo.png', height: 40),
                    const Icon(Icons.notifications_outlined, color: Color(0xFFD10C6A)),
                  ],
                ),
                const SizedBox(height: 20),

                // Image Carousel
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Wellness Hub',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),

                _wellnessCard(
                  title: 'Period Tracker',
                  subtitle: 'Track cycles, log period',
                  cardColor: const Color(0xFFB86A87),
                  buttonColor: const Color(0xFF9C3B5B),
                  buttonText: 'Log Now',
                ),
                _wellnessCard(
                  title: 'Calm Zone',
                  subtitle: 'Relax with meditation & music',
                  cardColor: const Color(0xFFC6B8DC),
                  buttonColor: const Color(0xFF8678B2),
                  buttonText: 'Explore',
                ),
                _wellnessCard(
                  title: 'Pregnancy',
                  subtitle: 'Baby Bump Diary',
                  cardColor: const Color(0xFFE577C0),
                  buttonColor: const Color(0xFFB61C9B),
                  buttonText: 'Open',
                ),
                _wellnessCard(
                  title: 'Relax & Play',
                  subtitle: 'Pop bubbles & fill colors to calm your mind',
                  cardColor: const Color(0xFFE49E84),
                  buttonColor: const Color(0xFFBF5740),
                  buttonText: 'Play Now',
                ),
                _wellnessCard(
                  title: 'Yoga',
                  subtitle: 'Poses for pregnancy & period relief',
                  cardColor: const Color(0xFF90CBC9),
                  buttonColor: const Color(0xFF50A1A1),
                  buttonText: 'Explore',
                ),
                _wellnessCard(
                  title: 'Nutrition & Remedies',
                  subtitle: 'Healthy diet & remedies',
                  cardColor: const Color(0xFF98DB7E),
                  buttonColor: const Color(0xFF4BB14B),
                  buttonText: 'Check Now',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wellnessCard({
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color buttonColor,
    required String buttonText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
