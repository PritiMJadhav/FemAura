// yoga_page.dart

import 'package:flutter/material.dart';

class YogaPage extends StatefulWidget {
  const YogaPage({super.key});

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPoseCard(
      String title, String subtitle, String imagePath, List<String> dos, List<String> donts) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: Hero(
          tag: imagePath, // Unique tag for animation
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.pink),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PoseDetailPage(
                title: title,
                imagePath: imagePath,
                dos: dos,
                donts: donts,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.pink.shade300),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pink,
          labelColor: Colors.pink,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: "Period Relief Yoga"),
            Tab(text: "Pregnancy Yoga"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Period Relief Yoga Poses
          ListView(
            children: [
              _buildPoseCard(
                "Ardha Matsyendrasana (Seated Spinal Twist)",
                "Eases bloating and supports relief from menstrual discomfort.",
                "assets/Ardha Matsyendrasana.png",
                ["Sit upright before twisting", "Breathe deeply during the pose"],
                ["Don’t overstretch your spine", "Avoid if you have severe back pain"],
              ),
              _buildPoseCard(
                "Eka Pada Rajakapotasana (Pigeon Pose)",
                "Releases pelvic tension and helps soothe cramps",
                "assets/Eka Pada Rajakapotasana.png",
                ["Keep hips square", "Support with a cushion if needed"],
                ["Don’t force the hip down", "Avoid with knee injuries"],
              ),
              _buildPoseCard(
                "Halasana (Plow Pose)",
                "Helps relieve menstrual backache and fatigue.",
                "assets/Halasana.png",
                ["Keep neck relaxed", "Exit slowly with support"],
                ["Avoid if you have neck or back injury", "Don’t hold too long"],
              ),
              _buildPoseCard(
                "Niravalasana (Sphinx Pose)",
                "Reduces stress and fatigue.",
                "assets/Niravalasana.png",
                ["Keep elbows under shoulders", "Relax belly while breathing"],
                ["Don’t overstretch lower back", "Avoid if severe back pain"],
              ),
              _buildPoseCard(
                "Supta Matsyendrasana (Supine Spinal Twist)",
                "Relaxes the lower back",
                "assets/Supta Matsyendrasana.png",
                ["Keep shoulders grounded", "Breathe slowly"],
                ["Don’t twist forcefully", "Avoid if severe spinal injury"],
              ),
            ],
          ),

          // Pregnancy Yoga Poses
          ListView(
            children: [
              _buildPoseCard(
                "Sukhasana (Simple Cross-Legged Pose)",
                "Encourages relaxation and supports calm breathing",
                "assets/Sukhasana.png",
                [
                  "Sit on a cushion or folded blanket for comfort and support.",
                  "Keep your spine straight and shoulders relaxed.",
                  "Breathe deeply and slowly to calm the mind.",
                  "Practice in a quiet, well-ventilated space.",
                  "Use wall support if needed for balance.", "Use props for support"
                ],
                [
                  "Don’t strain your hips or knees—use props if sitting is uncomfortable.",
                  "Avoid slouching or leaning forward."
                      "Don’t sit for too long without changing posture.",
                  "Avoid practicing on hard surfaces without cushioning.",
                  "Don’t force your legs into a tight cross if it feels uncomfortable.",
                ],
              ),
              _buildPoseCard(
                "Seated Side Stretch",
                "Opens the side body and improves flexibility",
                "assets/Seated Side Stretch.png",
                [
                  "Sit firmly on the ball with feet grounded and wide apart.",
                  "Keep your spine long and stretch gently to the side.",
                  "Engage core muscles slightly for stability.",
                  "Move slowly and breathe deeply throughout.",
                  "Use a wall or partner for extra support if needed.",
                ],
                [
                  "Don’t overextend or lean too far—keep movements controlled.",
                  "Avoid bouncing on the ball during the stretch.",
                  "Don’t hold your breath while stretching.",
                  "Avoid if you feel dizziness or instability.",
                  "Don’t practice on a slippery surface without grip.",
                ],
              ),
              _buildPoseCard(
                "Parighasana (Gate Pose)",
                "Stretches the side body and improves flexibility",
                "assets/Parighasana.png",
                [
                  "Sit comfortably with one leg extended and the other folded in.",
                  "Stretch gently to the side without compressing the belly.",
                  "Keep your spine long and chest open.",
                  "Use a cushion or block under the hip for extra support.",
                  "Breathe deeply and evenly throughout",
                ],
                [
                  "Don’t overstretch or force reaching the extended foot.",
                  "Avoid collapsing the chest forward.",
                  "Don’t hold the pose too long if it causes strain.",
                  "Avoid if you feel dizziness or pulling in the abdomen.",
                  "Don’t practice on a hard surface without support."
                ],
              ),

              _buildPoseCard(
                "Supported Bridge",
                "Opens the chest and relieves lower back tension",
                "assets/Supported Bridge.png",
                [
                  "Sit gently on the ball and walk your feet forward for support.",
                  "Keep shoulders relaxed and chest open while leaning back.",
                  "Engage core and pelvic floor muscles gently for stability.",
                  "Place feet firmly on the ground for balance.",
                  "Practice near a wall or with support for extra safety.",
                ],
                [
                  "Don’t let your hips sink too low or over-arch the back.",
                  "Avoid sudden movements or leaning too far back.",
                  "Don’t perform if you feel pressure in the lower belly.",
                  "Avoid if you feel dizzy, unstable, or short of breath.",
                  "Don’t use a ball that’s too small or too firm."
                ],
              ),

              _buildPoseCard(
                "Setu Bandhasana (Bridge Pose)",
                "Strengthens pelvic floor and relieves lower back pressure",
                "assets/Setu Bandhasana.png",
                [
                  "Keep feet hip-width apart and firmly grounded.",
                  "Lift hips gently without straining the belly.",
                  "Engage glutes and thighs for support.",
                  "Use a cushion or block under the lower back if needed.",
                  "Breathe deeply and evenly throughout",
                ],
                [
                  "Don’t over-arch the back or push the belly upward forcefully.",
                  "Avoid holding the pose for too long.",
                  "Don’t perform on a hard surface without support.",
                  "Avoid if experiencing pelvic pain or pressure.",
                  "Don’t jerk while coming down—lower slowly."
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Detailed Pose Page with Hero animation
class PoseDetailPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> dos;
  final List<String> donts;

  const PoseDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.dos,
    required this.donts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.pink),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Half Image with Hero animation
          Expanded(
            flex: 1,
            child: Hero(
              tag: imagePath,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          ),
          // Bottom Half Do's & Don'ts
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text("✅ Do's",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ...dos.map((d) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(d),
                  )),
                  const SizedBox(height: 10),
                  const Text("❌ Don'ts",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  ...donts.map((d) => ListTile(
                    leading: const Icon(Icons.cancel, color: Colors.red),
                    title: Text(d),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
