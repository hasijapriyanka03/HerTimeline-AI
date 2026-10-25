import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BreathingGameScreen extends StatefulWidget {
  final String userId;

  const BreathingGameScreen({super.key, required this.userId});

  @override
  State<BreathingGameScreen> createState() => _BreathingGameScreenState();
}

class _BreathingGameScreenState extends State<BreathingGameScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isBreathing = false;
  int _cycleCount = 0;
  String _breathPhase = 'Ready';
  Timer? _phaseTimer;
  int _sessionDuration = 0;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 100,
      end: 200,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _cycleCount = 0;
      _sessionDuration = 0;
    });

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _sessionDuration++);
    });

    _runBreathingCycle();
  }

  void _runBreathingCycle() {
    if (!_isBreathing) return;

    // Inhale (4 seconds)
    setState(() => _breathPhase = 'Breathe In...');
    _controller.forward();

    _phaseTimer = Timer(const Duration(seconds: 4), () {
      // Hold (4 seconds)
      setState(() => _breathPhase = 'Hold...');

      _phaseTimer = Timer(const Duration(seconds: 4), () {
        // Exhale (4 seconds)
        setState(() => _breathPhase = 'Breathe Out...');
        _controller.reverse();

        _phaseTimer = Timer(const Duration(seconds: 4), () {
          setState(() {
            _cycleCount++;
            if (_cycleCount >= 5) {
              _stopBreathing();
            } else {
              _runBreathingCycle();
            }
          });
        });
      });
    });
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
      _breathPhase = 'Complete!';
    });

    _phaseTimer?.cancel();
    _durationTimer?.cancel();
    _controller.stop();

    // Save session
    _apiService.updateBreathingGameSession(
      userId: widget.userId,
      duration: _sessionDuration,
      completed: _cycleCount >= 5,
    );

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great Job! 🌟'),
        content: Text(
          'You completed $_cycleCount breathing cycles in $_sessionDuration seconds.\n\n'
          'Regular breathing exercises can help reduce stress and anxiety during pregnancy.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cycleCount = 0;
                _sessionDuration = 0;
              });
              _startBreathing();
            },
            child: const Text('Do Another'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: const Color(0xFFAED6F1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isBreathing && _cycleCount == 0) ...[
              const Icon(Icons.spa, size: 80, color: Color(0xFF5DADE2)),
              const SizedBox(height: 20),
              const Text(
                'Calm Your Mind',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Take a few minutes to practice deep breathing.\n'
                  'This exercise helps reduce stress and promotes relaxation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startBreathing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  backgroundColor: const Color(0xFF5DADE2),
                ),
                child: const Text(
                  'Start Exercise',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ] else ...[
              Text(
                _breathPhase,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2874A6),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: _animation.value,
                    height: _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF5DADE2).withOpacity(0.6),
                          const Color(0xFF2874A6).withOpacity(0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5DADE2).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Cycle: $_cycleCount / 5',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'Duration: ${_sessionDuration}s',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              if (_isBreathing)
                ElevatedButton(
                  onPressed: _stopBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                  ),
                  child: const Text('Stop'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
