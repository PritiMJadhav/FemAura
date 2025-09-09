import 'package:flutter/material.dart';

class NutritionRemediesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Nutrition & Remedies", style: TextStyle(color: Colors.pink)),
        iconTheme: IconThemeData(color: Colors.pink),
      ),
      body: ListView(
        children: [
          // Period Relief Section
          _buildCategoryCard(
            "🌸 Period Relief",
            [
              _buildExpansionTile(
                "🥗 Nutrition",
                [
                  "Eat bananas & dark chocolate (help with serotonin and mood).",
                  "Add turmeric with warm milk (anti-inflammatory).",
                  "Snack on papaya & pineapple (reduce bloating).",
                  "Drink herbal teas (peppermint, cinnamon).",
                  "Add probiotics like yogurt for digestion.",
                  "Hydrate with coconut water.",
                ],
              ),
              _buildExpansionTile(
                "🌿 Remedies",
                [
                  "Massage lower abdomen with warm sesame or castor oil.",
                  "Try acupressure on inner calf and abdomen.",
                  "Hot water foot soak with Epsom salt.",
                  "Rest with legs elevated.",
                  "Stay active with light walking or cycling.",
                  "Track symptoms with a menstrual diary.",
                ],
              ),
            ],
          ),

          // Pregnancy Section
          _buildCategoryCard(
            "🤰 Pregnancy",
            [
              _buildExpansionTile(
                "🥗 Nutrition",
                [
                  "Eat whole grains (oats, brown rice, quinoa).",
                  "Add vitamin C-rich foods (oranges, strawberries).",
                  "Include avocados for healthy fats.",
                  "Snack on soaked almonds & walnuts.",
                  "Add leafy greens like kale & broccoli.",
                  "Limit spicy/junk food to reduce heartburn.",
                ],
              ),
              _buildExpansionTile(
                "🧘 Remedies",
                [
                  "Sleep on your left side for better blood flow.",
                  "Drink lemon water for nausea.",
                  "Wear loose, comfortable cotton clothes.",
                  "Do deep breathing & meditation daily.",
                  "Apply warm compress for back pain.",
                  "Take short breaks from long sitting.",
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for category card
  Widget _buildCategoryCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper for ExpansionTile
  Widget _buildExpansionTile(String title, List<String> items) {
    return ExpansionTile(
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      children: items
          .map((point) => ListTile(
        leading: Icon(Icons.check_circle, color: Colors.pink),
        title: Text(point),
      ))
          .toList(),
    );
  }
}
