import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;

class PeriodTrackerPage extends StatefulWidget {
  const PeriodTrackerPage({super.key});

  @override
  State<PeriodTrackerPage> createState() => _PeriodTrackerPageState();
}

class _PeriodTrackerPageState extends State<PeriodTrackerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _lastPeriodController = TextEditingController();

  DateTime? _selectedDate;
  bool _showResult = false;

  String nextPeriodDate = '';
  String fertileWindow = '';

  late final AnimationController _animController;
  late final Animation<double> _progressAnim;

  bool _showPeriodCard = false;
  bool _showFertileCard = false;

  // dynamic cycle fields
  int _cycleLen = 28;
  int _periodDays = 5; // default period length
  int _pmsDays = 3; // default PMS days
  int _ovulationDay = 14;
  int _fertileStartDay = 9;
  int _fertileEndDay = 15;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      // parse cycle length (guard against invalid input)
      final int parsed = int.tryParse(_cycleLengthController.text.trim()) ?? 28;
      // clamp to a sensible range to avoid weird values
      _cycleLen = parsed.clamp(10, 60);

      // sensible defaults (you can expose these to user if desired)
      _periodDays = (_cycleLen >= 7) ? 5 : (_cycleLen ~/ 4).clamp(1, _cycleLen);
      _pmsDays = 3;

      // ovulation day estimation: typically ~14 days before NEXT period.
      // That means ovulation occurs on day: cycleLength - 14 (counting day 1 as first day of period)
      _ovulationDay = (_cycleLen - 14).clamp(1, _cycleLen);

      // fertile window: ovulationDay -5  ... ovulationDay +1
      _fertileStartDay = (_ovulationDay - 5).clamp(1, _cycleLen);
      _fertileEndDay = (_ovulationDay + 1).clamp(1, _cycleLen);

      // recalc remaining days and adjust PMS if needed so sums == cycleLen
      final int fertileDays = _fertileEndDay - _fertileStartDay + 1;
      int remaining = _cycleLen - (_periodDays + _pmsDays + fertileDays);
      if (remaining < 0) {
        // reduce PMS first then period if needed
        final int reducePms = Math.min(_pmsDays, -remaining);
        _pmsDays -= reducePms;
        remaining += reducePms;
      }
      if (remaining < 0) {
        final int reducePeriod = Math.min(_periodDays, -remaining);
        _periodDays -= reducePeriod;
        remaining += reducePeriod;
      }

      // compute date outputs
      // CORRECTED logic for next period: next period = first day of last period + cycle length days
      // (e.g., if your cycle is 28 days and your last period started on Jan 1,
      // the next period is Jan 29 which is Jan 1 + 28 days)
      DateTime nextPeriod = _selectedDate!.add(Duration(days: _cycleLen));

      DateTime fertileStartDate =
          _selectedDate!.add(Duration(days: _fertileStartDay - 1));
      DateTime fertileEndDate =
          _selectedDate!.add(Duration(days: _fertileEndDay - 1));

      setState(() {
        nextPeriodDate = DateFormat('dd-MM-yyyy').format(nextPeriod);
        fertileWindow =
            "${DateFormat('dd-MM-yyyy').format(fertileStartDate)} to ${DateFormat('dd-MM-yyyy').format(fertileEndDate)}";
        _showResult = true;
        _showPeriodCard = false;
        _showFertileCard = false;
      });

      // start ring animation
      _animController.reset();
      _animController.forward();

      // stagger UI reveals (only two cards now)
      Future.delayed(const Duration(milliseconds: 450), () {
        setState(() => _showPeriodCard = true);
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() => _showFertileCard = true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select last period date & cycle length')),
      );
    }
  }

  void _goBackToForm() {
    setState(() {
      _showResult = false;
      _showPeriodCard = false;
      _showFertileCard = false;
    });
    _animController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // ensures full background fill
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEE9EE), Color(0xFFFFB7D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _showResult ? _buildResultScreen() : _buildFormScreen(),
      ),
    );
  }

  Widget _buildFormScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 19, 18, 18)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month,
                    size: 86, color: Color.fromARGB(255, 198, 34, 83)),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "Track Your Cycle",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 198, 34, 83)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter details to calculate your next period & fertile window.",
              style: TextStyle(color: Color.fromARGB(255, 198, 34, 83)),
            ),
            const SizedBox(height: 22),
            _buildLabeledInput("Enter Age :", _ageController, Icons.cake),
            const SizedBox(height: 14),
            _buildLabeledInput(
                "Average Length of cycle :", _cycleLengthController, Icons.loop),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildLabeledInput("First day of your last period :",
                    _lastPeriodController, Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 26),
            Center(
              child: ElevatedButton(
                onPressed: _calculatePeriod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Calculate",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    // compute segment days for painter
    final int fertileDays = _fertileEndDay - _fertileStartDay + 1;
    final int used = _periodDays + _pmsDays + fertileDays;
    final int remainingDays = (_cycleLen - used).clamp(0, _cycleLen);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color.fromARGB(255, 15, 11, 11)),
                onPressed: _goBackToForm,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your Predicted Info",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 198, 34, 83)),
            ),
            const SizedBox(height: 20),

            // Animated ovulation ring (dynamic segments)
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return SizedBox(
                  height: 220,
                  width: 220,
                  child: CustomPaint(
                    painter: AnimatedOvulationPainter(
                      progress: _progressAnim.value,
                      cycleLength: _cycleLen,
                      periodDays: _periodDays,
                      pmsDays: _pmsDays,
                      fertileStartDay: _fertileStartDay,
                      fertileEndDay: _fertileEndDay,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: Colors.pinkAccent),
                          const SizedBox(height: 6),
                          const Text(
                            "Estimated",
                            style: TextStyle(fontSize: 12, color: Colors.pink),
                          ),
                          const Text(
                            "Ovulation",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 26),

            // cards fade/slide in
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _showPeriodCard ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                offset: _showPeriodCard ? Offset.zero : const Offset(0, 0.06),
                child: _buildResultCard("Next Period Date", nextPeriodDate,
                    Colors.pink.shade50, Colors.pinkAccent, Icons.favorite),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _showFertileCard ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                offset: _showFertileCard ? Offset.zero : const Offset(0, 0.06),
                child: _buildResultCard("Fertile Window", fertileWindow,
                    Colors.green.shade50, Colors.green, Icons.eco),
              ),
            ),

            const SizedBox(height: 22),

            // NOTE: Graph removed as requested. If you want it back later, we can add
            // a configurable temperature / chart section.
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color bgColor,
      Color textColor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: textColor.withOpacity(0.12),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(value,
                    style:
                        TextStyle(fontSize: 15, color: textColor.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledInput(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.pinkAccent),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that draws the ovulation ring progressively according to progress (0.0 - 1.0)
class AnimatedOvulationPainter extends CustomPainter {
  final double progress; // 0 - 1
  final int cycleLength;
  final int periodDays;
  final int pmsDays;
  final int fertileStartDay;
  final int fertileEndDay;

  AnimatedOvulationPainter({
    required this.progress,
    required this.cycleLength,
    required this.periodDays,
    required this.pmsDays,
    required this.fertileStartDay,
    required this.fertileEndDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    // make radius account for half stroke so arc sits inside box
    final radius = (size.width / 2) - (stroke / 2);

    final fullCircle = 2 * Math.pi;

    // compute days for each segment
    final int fertileDays = (fertileEndDay - fertileStartDay + 1).clamp(0, cycleLength);
    int remainingDays = cycleLength - (periodDays + pmsDays + fertileDays);
    if (remainingDays < 0) remainingDays = 0;

    // convert to sweeps
    double periodSweep = (periodDays / cycleLength) * fullCircle;
    double fertileSweep = (fertileDays / cycleLength) * fullCircle;
    double pmsSweep = (pmsDays / cycleLength) * fullCircle;
    double remainingSweep = (remainingDays / cycleLength) * fullCircle;

    // start angle at top
    double start = -Math.pi / 2;

    final segments = <_Seg>[
      // order: PMS, Period, Fertile, Remaining (change if you want different order)
      _Seg(start, pmsSweep, Colors.orangeAccent),
      _Seg(start + pmsSweep, periodSweep, Colors.pinkAccent),
      _Seg(start + pmsSweep + periodSweep, fertileSweep, Colors.green),
      _Seg(start + pmsSweep + periodSweep + fertileSweep, remainingSweep, Colors.grey.shade300),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    final totalSweep = pmsSweep + periodSweep + fertileSweep + remainingSweep;
    final double drawSweepTotal = totalSweep * progress;

    double drawnSoFar = 0.0;
    for (final seg in segments) {
      final segSweep = seg.sweep;
      final double remainingToDraw = drawSweepTotal - drawnSoFar;
      if (remainingToDraw <= 0) {
        // draw only faint background of that segment
        paint.color = seg.color.withOpacity(0.12);
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
            seg.start, segSweep, false, paint);
      } else {
        final drawThis = remainingToDraw >= segSweep ? segSweep : remainingToDraw;
        // base faint arc
        paint.color = seg.color.withOpacity(0.12);
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
            seg.start, segSweep, false, paint);
        // visible portion
        if (drawThis > 0) {
          paint.color = seg.color;
          canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
              seg.start, drawThis, false, paint);
        }
        drawnSoFar += drawThis;
      }
    }

    // indicator dot at the end of drawn arc
    if (progress > 0) {
      final double endAngle = start + drawnSoFar;
      final Offset dot = Offset(center.dx + radius * Math.cos(endAngle),
          center.dy + radius * Math.sin(endAngle));
      final dotPaint = Paint()..color = Colors.pinkAccent;
      canvas.drawCircle(dot, 6, dotPaint);
      canvas.drawCircle(
          dot, 12, Paint()..color = Colors.pinkAccent.withOpacity(0.12));
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedOvulationPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.cycleLength != cycleLength ||
      oldDelegate.periodDays != periodDays ||
      oldDelegate.pmsDays != pmsDays ||
      oldDelegate.fertileStartDay != fertileStartDay ||
      oldDelegate.fertileEndDay != fertileEndDay;
}

class _Seg {
  final double start;
  final double sweep;
  final Color color;
  _Seg(this.start, this.sweep, this.color);
}