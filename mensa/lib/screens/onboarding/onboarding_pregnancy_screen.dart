import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';
import '../main_app_screen.dart';

class OnboardingPregnancyScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onComplete;
  final Map<String, dynamic>? initialData;

  const OnboardingPregnancyScreen({
    super.key,
    required this.userId,
    required this.onComplete,
    this.initialData,
  });

  @override
  State<OnboardingPregnancyScreen> createState() =>
      _OnboardingPregnancyScreenState();
}

class _OnboardingPregnancyScreenState extends State<OnboardingPregnancyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _lmpDate;
  DateTime? _dueDate;
  final List<String> _selectedAllergies = [];
  final List<String> _selectedConditions = [];

  bool _isLoading = false;

  final List<String> _commonAllergies = [
    'Penicillin',
    'Aspirin',
    'Ibuprofen',
    'Latex',
    'Pollen',
    'Dust',
    'Food Allergies',
    'None',
  ];

  final List<String> _commonConditions = [
    'Gestational Diabetes',
    'High Blood Pressure',
    'Thyroid Disorder',
    'Anemia',
    'Asthma',
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
    if (_lmpDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your last period date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // Calculate due date if not provided
      final dueDate = _dueDate ?? _lmpDate!.add(const Duration(days: 280));

      // Save user profile
      final profile = UserProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        trackerType: 'pregnancy',
        allergies: _selectedAllergies,
        medicalConditions: _selectedConditions,
      );

      final profileSuccess = await apiService.saveUserProfile(profile);

      // Save pregnancy data
      final pregnancySuccess = await apiService.createPregnancyProfile(
        widget.userId,
        _lmpDate!,
        dueDate,
      );

      if (profileSuccess && pregnancySuccess && mounted) {
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
    if (_currentPage < 2) {
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
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? const Color(0xFFFFB6C1)
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
                          _buildPregnancyInfoPage(),
                          _buildMedicalInfoPage(),
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
                                  color: Color(0xFFFFB6C1),
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
                              backgroundColor: const Color(0xFFFFB6C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _currentPage < 2 ? 'Next' : 'Complete Setup',
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
                colors: [Color(0xFFFFB6C1), Color(0xFFFFC9D4)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.child_care, size: 48, color: Colors.white),
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
              if (age == null || age < 15 || age > 50) {
                return 'Please enter a valid age (15-50)';
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

  Widget _buildPregnancyInfoPage() {
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
                colors: [Color(0xFFFFB6C1), Color(0xFFFFC9D4)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.pregnant_woman, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Pregnancy Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Help us track your pregnancy journey',
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
            leading: const Icon(Icons.calendar_today, color: Color(0xFFFFB6C1)),
            title: const Text('Last Menstrual Period *'),
            subtitle: Text(
              _lmpDate == null
                  ? 'Tap to select date'
                  : '${_lmpDate!.day}/${_lmpDate!.month}/${_lmpDate!.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 90)),
                firstDate: DateTime.now().subtract(const Duration(days: 280)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _lmpDate = date;
                  _dueDate = date.add(const Duration(days: 280));
                });
              }
            },
          ),
          const Divider(),
          if (_dueDate != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event, color: Color(0xFFFFB6C1)),
              title: const Text('Expected Due Date'),
              subtitle: Text(
                '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicalInfoPage() {
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
                colors: [Color(0xFFFFB6C1), Color(0xFFFFC9D4)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Medical Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Help us provide personalized care',
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
          const Text(
            'Allergies',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonAllergies.map((allergy) {
              final isSelected = _selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(allergy);
                    } else {
                      _selectedAllergies.remove(allergy);
                    }
                  });
                },
                selectedColor: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
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
