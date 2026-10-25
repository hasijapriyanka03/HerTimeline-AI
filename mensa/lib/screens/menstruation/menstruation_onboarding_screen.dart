import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menstruation_dashboard.dart';

class MenstruationOnboardingScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onTrackerChanged;

  const MenstruationOnboardingScreen({
    super.key,
    required this.userId,
    this.onTrackerChanged,
  });

  @override
  State<MenstruationOnboardingScreen> createState() =>
      _MenstruationOnboardingScreenState();
}

class _MenstruationOnboardingScreenState
    extends State<MenstruationOnboardingScreen> {
  int _currentStep = 0;

  // User responses
  String? _name;
  int? _age;
  bool? _hasPCOS;
  bool? _irregularCycles;
  List<String> _symptoms = [];

  // Soft, calming colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);

  final List<String> _pcosSymptoms = [
    'Irregular periods',
    'Heavy bleeding',
    'Acne',
    'Weight gain',
    'Hair loss',
    'Excess facial/body hair',
    'Darkening of skin',
    'Difficulty getting pregnant',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: _lightPink,
              valueColor: AlwaysStoppedAnimation<Color>(_darkPink),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _darkPink,
                          side: BorderSide(color: _darkPink, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkPink,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _darkPink.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == 4 ? 'Get Started' : 'Continue',
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildBasicInfoStep();
      case 2:
        return _buildPCOSQuestionStep();
      case 3:
        return _buildIrregularCyclesStep();
      case 4:
        return _buildSymptomsStep();
      default:
        return Container();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryPink, _lightPink],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text(
          'Welcome to\nCycle Tracker',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Let\'s personalize your experience with a few quick questions',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _purpleAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                Icons.calendar_today,
                'Track your cycle',
                'Log periods, symptoms, and moods',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.insights,
                'Get insights',
                'AI-powered predictions and tips',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.favorite,
                'PCOS support',
                'Specialized tracking for PCOS/PCOD',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryPink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What\'s your name?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _name = value),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: _lightPink,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How old are you?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) =>
                    setState(() => _age = int.tryParse(value)),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  filled: true,
                  fillColor: _lightPink,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.cake),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPCOSQuestionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Have you been diagnosed with PCOS or PCOD?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us provide specialized tracking and insights',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          title: 'Yes, I have PCOS/PCOD',
          description: 'I\'ve been diagnosed by a healthcare provider',
          icon: Icons.check_circle,
          isSelected: _hasPCOS == true,
          onTap: () => setState(() => _hasPCOS = true),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          title: 'No, I don\'t have PCOS/PCOD',
          description: 'I have regular menstrual cycles',
          icon: Icons.cancel,
          isSelected: _hasPCOS == false,
          onTap: () => setState(() => _hasPCOS = false),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PCOS (Polycystic Ovary Syndrome) affects 5 in 10 women and can cause irregular periods, weight gain, and other symptoms.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIrregularCyclesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Do you have irregular menstrual cycles?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Irregular cycles are longer than 35 days or vary significantly',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        _buildOptionCard(
          title: 'Yes, my cycles are irregular',
          description: 'Cycles longer than 35 days or very unpredictable',
          icon: Icons.warning_amber,
          isSelected: _irregularCycles == true,
          onTap: () => setState(() => _irregularCycles = true),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          title: 'No, my cycles are regular',
          description: 'Cycles are 21-35 days and fairly consistent',
          icon: Icons.check_circle,
          isSelected: _irregularCycles == false,
          onTap: () => setState(() => _irregularCycles = false),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Do you experience any of these symptoms?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply (optional)',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pcosSymptoms.map((symptom) {
              final isSelected = _symptoms.contains(symptom);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _symptoms.remove(symptom);
                    } else {
                      _symptoms.add(symptom);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _purpleAccent
                        : _purpleAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        if (_hasPCOS == true || _irregularCycles == true)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _purpleAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _purpleAccent, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: _purpleAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You\'ll get access to PCOS-specific tracking features and insights!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _darkPink : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _darkPink
                    : _primaryPink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : _darkPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _darkPink : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: _darkPink, size: 24),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _name != null && _name!.isNotEmpty && _age != null && _age! > 0;
      case 2:
        return _hasPCOS != null;
      case 3:
        return _irregularCycles != null;
      case 4:
        return true; // Symptoms are optional
      default:
        return false;
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Save preferences and navigate
      await _savePreferences();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenstruationDashboard(
              userId: widget.userId,
              hasPCOS: _hasPCOS == true || _irregularCycles == true,
            ),
          ),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('menstruation_user_name', _name ?? '');
    await prefs.setInt('menstruation_user_age', _age ?? 0);
    await prefs.setBool('menstruation_has_pcos', _hasPCOS == true);
    await prefs.setBool(
      'menstruation_irregular_cycles',
      _irregularCycles == true,
    );
    await prefs.setStringList('menstruation_symptoms', _symptoms);
    await prefs.setBool('menstruation_onboarding_complete', true);
  }
}
