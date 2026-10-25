import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../services/api_service.dart';

class UserProfileSetupScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onComplete;

  const UserProfileSetupScreen({
    super.key,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _bloodType = 'Unknown';
  final List<String> _selectedMedicalConditions = [];
  final List<String> _selectedAllergies = [];
  final List<String> _selectedMedications = [];

  bool _isLoading = false;

  final List<String> _bloodTypes = [
    'Unknown',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _commonConditions = [
    'PCOS',
    'Endometriosis',
    'Diabetes',
    'Hypertension',
    'Thyroid Disorder',
    'Anemia',
    'Asthma',
    'Migraine',
  ];

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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bloodType: _bloodType,
        medicalConditions: _selectedMedicalConditions,
        allergies: _selectedAllergies,
        medications: _selectedMedications,
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
      );

      final apiService = ApiService();
      final success = await apiService.saveUserProfile(profile);

      if (success && mounted) {
        widget.onComplete();
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      print('Error saving profile: $e');
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
    if (_currentPage < 3) {
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: List.generate(4, (index) {
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
                          _buildPhysicalInfoPage(),
                          _buildMedicalInfoPage(),
                          _buildEmergencyContactPage(),
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
                              _currentPage < 3 ? 'Next' : 'Complete Setup',
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
          const Icon(Icons.person, size: 64, color: Color(0xFFFFB6C1)),
          const SizedBox(height: 16),
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s start with your basic details',
            style: TextStyle(fontSize: 16, color: Colors.black54),
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
              if (age == null || age < 10 || age > 100) {
                return 'Please enter a valid age (10-100)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _bloodType,
            decoration: InputDecoration(
              labelText: 'Blood Type',
              prefixIcon: const Icon(Icons.bloodtype_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _bloodTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() => _bloodType = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.monitor_weight_outlined,
            size: 64,
            color: Color(0xFFFFB6C1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Physical Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us provide personalized health insights',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _heightController,
            decoration: InputDecoration(
              labelText: 'Height *',
              prefixIcon: const Icon(Icons.height),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: 'cm',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your height';
              }
              final height = double.tryParse(value);
              if (height == null || height < 100 || height > 250) {
                return 'Please enter a valid height (100-250 cm)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: 'Weight *',
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: 'kg',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your weight';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight < 30 || weight > 200) {
                return 'Please enter a valid weight (30-200 kg)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (_heightController.text.isNotEmpty &&
              _weightController.text.isNotEmpty)
            _buildBMICard(),
        ],
      ),
    );
  }

  Widget _buildBMICard() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) return const SizedBox();

    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal';
      color = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
    } else {
      category = 'Obese';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI: ${bmi.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(category, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
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
          const Icon(
            Icons.medical_information_outlined,
            size: 64,
            color: Color(0xFFFFB6C1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Optional but helps us provide better care',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          const Text(
            'Medical Conditions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonConditions.map((condition) {
              final isSelected = _selectedMedicalConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMedicalConditions.add(condition);
                    } else {
                      _selectedMedicalConditions.remove(condition);
                    }
                  });
                },
                selectedColor: const Color(0xFFFFB6C1).withOpacity(0.3),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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
                selectedColor: const Color(0xFFBA68C8).withOpacity(0.3),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.emergency_outlined,
            size: 64,
            color: Color(0xFFFFB6C1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Optional but recommended for safety',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emergencyContactController,
            decoration: InputDecoration(
              labelText: 'Emergency Contact Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emergencyPhoneController,
            decoration: InputDecoration(
              labelText: 'Emergency Contact Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information is encrypted and secure. We never share your data without permission.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
