import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../main_app_screen.dart';

class OnboardingMenopauseScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onComplete;
  final Map<String, dynamic>? initialData;

  const OnboardingMenopauseScreen({
    super.key,
    required this.userId,
    required this.onComplete,
    this.initialData,
  });

  @override
  State<OnboardingMenopauseScreen> createState() =>
      _OnboardingMenopauseScreenState();
}

class _OnboardingMenopauseScreenState extends State<OnboardingMenopauseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _symptomsStartDate;
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedConditions = [];

  bool _isLoading = false;

  final List<String> _commonSymptoms = [
    'Hot Flashes',
    'Night Sweats',
    'Mood Changes',
    'Sleep Problems',
    'Fatigue',
    'Weight Gain',
    'Memory Issues',
    'Joint Pain',
  ];

  final List<String> _commonConditions = [
    'Osteoporosis',
    'High Blood Pressure',
    'Diabetes',
    'Thyroid Disorder',
    'Heart Disease',
    'Arthritis',
    'None',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // Save user profile
      final profile = UserProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        trackerType: 'menopause',
        medicalConditions: _selectedConditions,
      );

      final profileSuccess = await apiService.saveUserProfile(profile);

      // Save initial menopause log if symptoms started
      if (_symptomsStartDate != null) {
        final menopauseLog = {
          'user_id': widget.userId,
          'date': DateTime.now().toIso8601String(),
          'symptoms': _selectedSymptoms,
          'severity': 'moderate',
          'mood': 'normal',
          'notes':
              'Initial setup - symptoms started ${_symptomsStartDate!.year}',
        };

        await apiService.addMenopauseLog(menopauseLog);
      }

      if (profileSuccess && mounted) {
        // Navigate back to main app screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainAppScreen(userId: widget.userId),
          ),
          (route) => false,
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? const Color(0xFFFF8A80)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                        },
                        children: [
                          _buildBasicInfoPage(),
                          _buildMenopauseInfoPage(),
                        ],
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFFF8A80),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A80),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _currentPage < 1 ? 'Next' : 'Complete Setup',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8A80), Color(0xFFFFAB91)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A80).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Let\'s start with your basic details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(
              labelText: 'Age *',
              prefixIcon: const Icon(Icons.cake_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: 'years',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final age = int.tryParse(value);
              if (age == null || age < 40 || age > 70) {
                return 'Please enter a valid age (40-70)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: 'Height *',
                    prefixIcon: const Icon(Icons.height),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: 'cm',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight *',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30 || weight > 200) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenopauseInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8A80), Color(0xFFFFAB91)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A80).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Menopause Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Help us understand your journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today, color: Color(0xFFFF8A80)),
            title: const Text('When did symptoms start?'),
            subtitle: Text(
              _symptomsStartDate == null
                  ? 'Tap to select (optional)'
                  : '${_symptomsStartDate!.month}/${_symptomsStartDate!.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365)),
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _symptomsStartDate = date);
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Common Symptoms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
                selectedColor: const Color(0xFFFF8A80).withValues(alpha: 0.3),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Medical Conditions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonConditions.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConditions.add(condition);
                    } else {
                      _selectedConditions.remove(condition);
                    }
                  });
                },
                selectedColor: const Color(0xFFBA68C8).withValues(alpha: 0.3),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
