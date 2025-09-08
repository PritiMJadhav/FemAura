import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HydrationReminderPage extends StatefulWidget {
  const HydrationReminderPage({super.key});

  @override
  State<HydrationReminderPage> createState() => _HydrationReminderPageState();
}

class _HydrationReminderPageState extends State<HydrationReminderPage> {
  int glasses = 0; // today's progress
  int goalGlasses = 8; // default goal
  bool remindersOn = true;
  String reminderFrequency = "Every 1 hour";
  String lastSavedDate = "";

  final List<String> frequencyOptions = [
    "Every 1 hour",
    "Every 2 hours",
    "Every 3 hours",
    "Every 4 hours",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load saved data
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      glasses = prefs.getInt('glasses') ?? 0;
      goalGlasses = prefs.getInt('goalGlasses') ?? 8;
      remindersOn = prefs.getBool('remindersOn') ?? true;
      reminderFrequency =
          prefs.getString('reminderFrequency') ?? "Every 1 hour";
      lastSavedDate = prefs.getString('lastSavedDate') ?? today;
    });

    // Reset if a new day started
    if (lastSavedDate != today) {
      setState(() {
        glasses = 0;
        lastSavedDate = today;
      });
      prefs.setInt('glasses', 0);
      prefs.setString('lastSavedDate', today);
    }
  }

  // Save data
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('glasses', glasses);
    prefs.setInt('goalGlasses', goalGlasses);
    prefs.setBool('remindersOn', remindersOn);
    prefs.setString('reminderFrequency', reminderFrequency);
    prefs.setString('lastSavedDate', lastSavedDate);
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        goalGlasses > 0 ? glasses / goalGlasses : 0; // progress ratio

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFE1F5FE),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Back Button + Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Hydration Reminder 💧",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),

                // Circular Progress (Today's Progress)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 16,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.lightBlue),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$glasses",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "of $goalGlasses glasses",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Quick Add Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGlassButton(1),
                    const SizedBox(width: 20),
                    _buildGlassButton(2),
                  ],
                ),
                const SizedBox(height: 30),

                // Daily Goal
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.lightBlue),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Daily Goal: $goalGlasses glasses",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.lightBlue),
                          onPressed: () {
                            _showGoalDialog();
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reminder Settings
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.lightBlue),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                "Hydration Reminders",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Switch(
                              value: remindersOn,
                              onChanged: (val) {
                                setState(() {
                                  remindersOn = val;
                                });
                                _saveData();
                              },
                              activeColor: Colors.lightBlue,
                            )
                          ],
                        ),
                        if (remindersOn) ...[
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  color: Colors.lightBlue),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: reminderFrequency,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: frequencyOptions
                                      .map((String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      reminderFrequency = newValue!;
                                    });
                                    _saveData();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Motivational Quote
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "“Drink water like it’s your superpower 🚰✨”",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add Glass Button
  Widget _buildGlassButton(int count) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        elevation: 3,
      ),
      onPressed: () {
        setState(() {
          glasses += count;
          if (glasses > goalGlasses) glasses = goalGlasses;
          _saveData();
        });
      },
      child: Text("+$count glass${count > 1 ? 'es' : ''}",
          style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  // Edit Daily Goal
  void _showGoalDialog() {
    TextEditingController goalController =
        TextEditingController(text: goalGlasses.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Daily Goal"),
        content: TextField(
          controller: goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Number of glasses",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                goalGlasses = int.tryParse(goalController.text) ?? 8;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
