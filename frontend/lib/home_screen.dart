import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/NutritionRemedies.dart';
import 'package:frontend/YogaPose.dart';
import 'package:frontend/calm_zone.dart';
import 'package:frontend/period_tracker.dart';
import 'package:frontend/BumpBook.dart';
import 'package:frontend/profile.dart';
import 'screens/main_menu.dart';

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
    'assets/slide4.png',
    'assets/slide5.png',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()), // your ProfilePage
                        );
                      },
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/Profile.jpg'),
                      ),
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

                // Cards with gradient backgrounds
                _wellnessCard(
                  title: 'Period Tracker',
                  subtitle: 'Track cycles, log period',
                  gradientColors: [Color(0xFFB86A87), Color(0xFF9C3B5B)],
                  buttonColor: Color(0xFF9C3B5B),
                  buttonText: 'Log Now',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PeriodTrackerPage()),
                    );
                  },
                ),

                _wellnessCard(
                  title: 'Calm Zone',
                  subtitle: 'Relax with meditation & music',
                  gradientColors: [Color(0xFFC6B8DC), Color(0xFF8678B2)],
                  buttonColor: Color(0xFF8678B2),
                  buttonText: 'Explore',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  CalmZonePage()),
                    );
                  },

                ),
                _wellnessCard(
                  title: 'Bump Book',
                  subtitle: 'Keep track of your beautiful pregnancy journey',
                  gradientColors: [Color(0xFFE577C0), Color(0xFFB61C9B)],
                  buttonColor: Color(0xFFB61C9B),
                  buttonText: 'Open',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Bumpbook()),
                    );
                  },
                ),
                _wellnessCard(
                  title: 'Relax & Play',
                  subtitle: 'Pop bubbles & fill colors to calm your mind',
                  gradientColors: [Color(0xFFE49E84), Color(0xFFBF5740)],
                  buttonColor: Color(0xFFBF5740),
                  buttonText: 'Play Now',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
                  },
                ),
                _wellnessCard(
                  title: 'Yoga',
                  subtitle: 'Poses for pregnancy & period relief',
                  gradientColors: [Color(0xFFB1BFF4), Color(0xFF969CED)],
                  buttonColor: Color(0xFF6387C6),
                  buttonText: 'Explore',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YogaPage()),
                    );
                  },
                ),
                _wellnessCard(
                  title: 'Nutrition & Remedies',
                  subtitle: 'Healthy diet & remedies',
                  gradientColors: [Color(0xFFAED1AF), Color(0xFF82BC85)],
                  buttonColor: Color(0xFF4BB14B),
                  buttonText: 'Check Now',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  NutritionRemediesPage()),
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

  // _wellnessCard widget
  Widget _wellnessCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color buttonColor,
    required String buttonText,
    VoidCallback? onTap,
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
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: onTap, // ← FIXED HERE
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
