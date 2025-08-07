import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodTrackerPage extends StatefulWidget {
  const PeriodTrackerPage({super.key});

  @override
  State<PeriodTrackerPage> createState() => _PeriodTrackerPageState();
}

class _PeriodTrackerPageState extends State<PeriodTrackerPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _lastPeriodController = TextEditingController();

  DateTime? _selectedDate;
  bool _showResult = false;

  // Output
  String nextPeriodDate = '';
  String fertileWindow = '';

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _lastPeriodController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _calculatePeriod() {
    if (_selectedDate != null && _cycleLengthController.text.isNotEmpty) {
      int cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;
      DateTime nextPeriod = _selectedDate!.add(Duration(days: cycleLength));
      DateTime fertileStart = _selectedDate!.add(const Duration(days: 10));
      DateTime fertileEnd = _selectedDate!.add(const Duration(days: 15));

      setState(() {
        nextPeriodDate = DateFormat('dd-MM-yyyy').format(nextPeriod);
        fertileWindow =
            "${DateFormat('dd-MM-yyyy').format(fertileStart)} to ${DateFormat('dd-MM-yyyy').format(fertileEnd)}";
        _showResult = true;
      });
    }
  }

  void _goBackToForm() {
    setState(() {
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showResult ? _buildResultScreen() : _buildFormScreen(),
    );
  }

  Widget _buildFormScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 8),

            // Image
            Center(
              child: Image.asset(
                'assets/calendar.png', 
                height: 120,
              ),
            ),

            const SizedBox(height: 24),

            // Age
            const Text("Enter Age :", style: TextStyle(fontSize: 16)),
            _buildInputField(_ageController),

            const SizedBox(height: 16),

            // Cycle Length
            const Text("Average Length of cycle :", style: TextStyle(fontSize: 16)),
            _buildInputField(_cycleLengthController),

            const SizedBox(height: 16),

            // Last Period Date
            const Text("First day of your last period :", style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(child: _buildInputField(_lastPeriodController)),
            ),

            const SizedBox(height: 30),

            // Calculate Button
            Center(
              child: ElevatedButton(
                onPressed: _calculatePeriod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF980F3B), // Maroon button
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Calculate", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBackToForm,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Predicted Info",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Next Period Date: $nextPeriodDate", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Fertile Window: $fertileWindow", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B6C1), // Pink shade like image
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
