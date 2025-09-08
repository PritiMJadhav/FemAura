import 'package:flutter/material.dart';
import 'profile.dart'; // ✅ Import Profile Page

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/Profile.jpg'),
                    ),
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.pink.shade300,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Start Your Wellness Journey......',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Wellness Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Wellness Cards
              _wellnessCard(
                title: 'Period Tracker',
                subtitle: 'Track cycles, log period',
                color: const Color(0xFFB86A87),
                buttonText: 'Log Now',
              ),
              _wellnessCard(
                title: 'Calm Zone',
                subtitle: 'Relax with meditation & music',
                color: const Color(0xFFD6C8E7),
                buttonText: 'Explore',
              ),
              _wellnessCard(
                title: 'Pregnancy',
                subtitle: 'Baby Bump Diary',
                color: const Color(0xFFEA75BF),
                buttonText: 'Open',
              ),
              _wellnessCard(
                title: 'Relax & Play',
                subtitle: 'Pop bubbles & fill colors to calm your mind',
                color: const Color(0xFFE69E85),
                buttonText: 'Play Now',
              ),
              _wellnessCard(
                title: 'Yoga',
                subtitle: 'Poses for pregnancy & period relief',
                color: const Color(0xFF8CC8C8),
                buttonText: 'Explore',
              ),
              _wellnessCard(
                title: 'Nutrition & Remedies',
                subtitle: 'Healthy diet & remedies',
                color: const Color(0xFF9BE37D),
                buttonText: 'Check Now',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Wellness Card Widget
  Widget _wellnessCard({
    required String title,
    required String subtitle,
    required Color color,
    required String buttonText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
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
              onPressed: () {
                // 👉 TODO: Add navigation for each card here later
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
