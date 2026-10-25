import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/api_service.dart';
import '../../models/daily_log.dart';

class VoiceDumpScreen extends StatefulWidget {
  final String userId;

  const VoiceDumpScreen({super.key, required this.userId});

  @override
  State<VoiceDumpScreen> createState() => _VoiceDumpScreenState();
}

class _VoiceDumpScreenState extends State<VoiceDumpScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _pulseController;
  late FlutterSoundRecorder _audioRecorder;

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioFilePath;
  String? _selectedMood;
  final List<String> _selectedSymptoms = [];
  String _errorMessage = '';
  String _recordingDuration = '0:00';

  // Color palette
  static const Color _primaryPurple = Color(0xFFD4C4E8);
  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _redAccent = Color(0xFFE8C4C4);

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.openRecorder();
      debugPrint('✅ Audio recorder initialized');
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize audio recorder: $e';
        });
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Microphone permission denied. Please enable it in settings.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await Permission.microphone.isDenied;
      if (hasPermission) {
        await _requestMicrophonePermission();
        return;
      }

      // Get the app's temporary directory for storing audio
      final tempDir = Directory.systemTemp;
      final audioPath =
          '${tempDir.path}/voice_dump_${DateTime.now().millisecondsSinceEpoch}.wav';

      setState(() {
        _isRecording = true;
        _errorMessage = '';
        _recordingDuration = '0:00';
      });

      debugPrint('🎤 Starting audio recording to: $audioPath');

      await _audioRecorder.startRecorder(
        toFile: audioPath,
        codec: Codec.pcm16WAV,
      );

      _audioFilePath = audioPath;

      // Update recording duration every second
      Future.delayed(const Duration(seconds: 1), _updateRecordingDuration);
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
          _errorMessage = 'Failed to start recording: $e';
        });
      }
    }
  }

  void _updateRecordingDuration() {
    if (_isRecording && mounted) {
      setState(() {
        final parts = _recordingDuration.split(':');
        int seconds = int.parse(parts[1]);
        int minutes = int.parse(parts[0]);

        seconds++;
        if (seconds >= 60) {
          minutes++;
          seconds = 0;
        }

        _recordingDuration =
            '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
      });

      if (_isRecording) {
        Future.delayed(const Duration(seconds: 1), _updateRecordingDuration);
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stopRecorder();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _audioFilePath = path;
        });
      }

      debugPrint('🎤 Recording stopped. File: $path');
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error stopping recording: $e';
        });
      }
    }
  }

  Future<void> _processRecording() async {
    if (_audioFilePath == null || _audioFilePath!.isEmpty) {
      setState(() {
        _errorMessage = 'No audio recorded. Please record again.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      debugPrint('🎤 Processing audio file: $_audioFilePath');

      // Read audio file and convert to base64
      final audioFile = File(_audioFilePath!);
      if (!audioFile.existsSync()) {
        throw Exception('Audio file not found');
      }

      final audioBytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      debugPrint('📊 Audio file size: ${audioBytes.length} bytes');
      debugPrint('📊 Base64 length: ${base64Audio.length} characters');

      // Send to backend for emotion detection
      final emotionResult = await _apiService.detectAudioEmotion(
        base64Audio: base64Audio,
        mimeType: 'audio/wav',
      );

      debugPrint('🎯 Emotion detection result: $emotionResult');

      if (!mounted) return;

      if (emotionResult != null && emotionResult['success'] == true) {
        final mood = emotionResult['mood'] ?? 'Calm';
        final symptoms = emotionResult['symptoms'] != null
            ? List<String>.from(
                (emotionResult['symptoms'] as List).cast<String>(),
              )
            : <String>[];

        setState(() {
          _selectedMood = mood;
          _selectedSymptoms.clear();
          _selectedSymptoms.addAll(symptoms.cast<String>());
          _isProcessing = false;
        });

        debugPrint('✅ Mood detected: $mood');
        debugPrint('✅ Symptoms: $symptoms');
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              emotionResult?['error'] ?? 'Failed to detect emotion from audio';
        });
      }
    } catch (e) {
      debugPrint('❌ Error processing audio: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Failed to process audio: $e';
        });
      }
    }
  }

  Future<void> _submitLog() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please process your recording first')),
      );
      return;
    }

    try {
      final log = DailyLog(
        userId: widget.userId,
        date: DateTime.now(),
        mood: _selectedMood!,
        symptoms: _selectedSymptoms,
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
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save log. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Error submitting log: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving log: $e';
        });
      }
    }
  }

  void _resetRecording() {
    setState(() {
      _audioFilePath = null;
      _selectedMood = null;
      _selectedSymptoms.clear();
      _errorMessage = '';
      _isRecording = false;
      _isProcessing = false;
      _recordingDuration = '0:00';
    });
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
          'Voice Dump',
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
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryPurple, _lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Speak Freely 🎤',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Record as much as you want, then process',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _redAccent),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),

              // Recording Button
              if (_audioFilePath == null && _selectedMood == null)
                ScaleTransition(
                  scale: Tween(
                    begin: 0.95,
                    end: 1.05,
                  ).animate(_pulseController),
                  child: GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? _redAccent : _primaryPurple,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? _redAccent : _primaryPurple)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 60,
                            color: Colors.white,
                          ),
                          if (_isRecording) ...[
                            const SizedBox(height: 8),
                            Text(
                              _recordingDuration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              if (_isProcessing)
                Column(
                  children: [
                    const CircularProgressIndicator(color: _primaryPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Processing your voice...',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Recording Status
              if (_audioFilePath != null && _selectedMood == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recording Ready',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: $_recordingDuration',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File: ${_audioFilePath!.split('/').last}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Process Button (shown after recording)
              if (_audioFilePath != null && _selectedMood == null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _processRecording,
                        icon: const Icon(Icons.psychology),
                        label: const Text('Process'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetRecording,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Mood Selection (shown after processing)
              if (_selectedMood != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detected Mood',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(_selectedMood!),
                            backgroundColor: _primaryPurple.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedSymptoms.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Detected Symptoms',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _selectedSymptoms
                              .map(
                                (symptom) => Chip(
                                  label: Text(symptom),
                                  backgroundColor: _greenAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _greenAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Log'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Start Over'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
