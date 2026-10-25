import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../models/daily_log.dart';

class BodySelfieScreen extends StatefulWidget {
  final String userId;

  const BodySelfieScreen({super.key, required this.userId});

  @override
  State<BodySelfieScreen> createState() => _BodySelfieScreenState();
}

class _BodySelfieScreenState extends State<BodySelfieScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  String? _selectedMood;
  final List<String> _selectedSymptoms = [];
  bool _isAnalyzing = false;

  // Color palette
  static const Color _primaryPurple = Color(0xFFD4C4E8);
  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  final List<String> _moods = [
    'Happy',
    'Calm',
    'Anxious',
    'Tired',
    'Energetic',
    'Stressed',
  ];

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isAnalyzing = true;
        });

        // Simulate AI analysis
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _selectedMood = 'Calm';
            _selectedSymptoms.addAll(['Bloating']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submitLog() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
      return;
    }

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
          'Body Selfie',
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
                      'Visual Check-in 📸',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a selfie to log your physical state',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Image Preview or Camera Button
              if (_selectedImage == null)
                GestureDetector(
                  onTap: _isAnalyzing ? null : _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _primaryPurple.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: _primaryPurple.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tap to take a selfie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Our AI will analyze your appearance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake Photo'),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Analysis Status
              if (_isAnalyzing)
                Column(
                  children: [
                    const CircularProgressIndicator(color: _primaryPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Analyzing your selfie...',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

              // Mood & Symptoms
              if (_selectedMood != null && !_isAnalyzing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analysis Results',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Detected Mood',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(_selectedMood!),
                            backgroundColor: _primaryPurple.withOpacity(0.2),
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
                                  backgroundColor: _greenAccent.withOpacity(
                                    0.2,
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
                SizedBox(
                  width: double.infinity,
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
