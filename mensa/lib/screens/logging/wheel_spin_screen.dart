import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/api_service.dart';
import '../../models/daily_log.dart';

class WheelSpinScreen extends StatefulWidget {
  final String userId;

  const WheelSpinScreen({super.key, required this.userId});

  @override
  State<WheelSpinScreen> createState() => _WheelSpinScreenState();
}

class _WheelSpinScreenState extends State<WheelSpinScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _wheelController;
  late AnimationController _confettiController;

  bool _isSpinning = false;
  String? _selectedMood;
  String? _selectedSymptom;

  // Color palette
  static const Color _primaryPurple = Color(0xFFD4C4E8);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  final List<String> _moods = [
    'Happy 😊',
    'Calm 😌',
    'Anxious 😰',
    'Tired 😴',
    'Energetic ⚡',
    'Stressed 😤',
  ];

  final List<String> _symptoms = [
    'None',
    'Cramps',
    'Bloating',
    'Headache',
    'Fatigue',
    'Nausea',
  ];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);

    // Random selection
    final random = math.Random();
    final moodIndex = random.nextInt(_moods.length);
    final symptomIndex = random.nextInt(_symptoms.length);

    debugPrint(
      '🎡 Spinning wheel - Mood index: $moodIndex, Symptom index: $symptomIndex',
    );

    // Animate the wheel
    await _wheelController.forward(from: 0.0);

    if (mounted) {
      setState(() {
        _selectedMood = _moods[moodIndex];
        _selectedSymptom = _symptoms[symptomIndex];
        _isSpinning = false;
      });

      debugPrint(
        '✅ Wheel stopped - Selected: ${_moods[moodIndex]}, ${_symptoms[symptomIndex]}',
      );

      // Play confetti animation
      await _confettiController.forward(from: 0.0);
    }
  }

  Future<void> _submitLog() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please spin the wheel first!')),
      );
      return;
    }

    final log = DailyLog(
      userId: widget.userId,
      date: DateTime.now(),
      mood: _selectedMood!.split(' ')[0],
      symptoms: _selectedSymptom != null && _selectedSymptom != 'None'
          ? [_selectedSymptom!]
          : [],
      water: 8.0,
      weight: 0.0,
    );

    final success = await _apiService.addDailyLog(log);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Log saved! 🎉'),
          backgroundColor: _greenAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wheel Spin Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spinning Wheel with Pointer
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Pointer at top
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 0,
                      height: 0,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CustomPaint(
                        size: const Size(40, 20),
                        painter: PointerPainter(),
                      ),
                    ),
                  ),
                  // Wheel container
                  Container(
                    width: 280,
                    height: 280,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Wheel
                        RotationTransition(
                          turns: Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(_wheelController),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _primaryPurple,
                                  _primaryPurple.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: WheelPainter(
                                segments: _moods.length,
                                colors: [
                                  Colors.pink[300]!,
                                  Colors.purple[300]!,
                                  Colors.blue[300]!,
                                  Colors.green[300]!,
                                  Colors.orange[300]!,
                                  Colors.red[300]!,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Center circle
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSpinning
                                ? Icons.hourglass_empty
                                : Icons.touch_app,
                            color: _primaryPurple,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Spin Button
              ElevatedButton.icon(
                onPressed: _isSpinning ? null : _spinWheel,
                icon: const Icon(Icons.casino),
                label: Text(_isSpinning ? 'Spinning...' : 'SPIN THE WHEEL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Results
              if (_selectedMood != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Mood',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedMood!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Symptom',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedSymptom ?? 'None',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitLog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _greenAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save Log'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final int segments;
  final List<Color> colors;

  WheelPainter({required this.segments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < segments; i++) {
      paint.color = colors[i % colors.length];
      final startAngle = (i * 360 / segments) * math.pi / 180;
      final sweepAngle = (360 / segments) * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) => false;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw a triangle pointing down
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2 + 10, size.height);
    path.lineTo(size.width / 2 - 10, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => false;
}
