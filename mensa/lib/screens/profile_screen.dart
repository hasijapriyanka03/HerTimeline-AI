import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import 'wallet_screen.dart';
import 'voucher_screen.dart';
import 'auth/login_screen.dart';
import 'education_chat_screen.dart';
import 'agora_conversational_voice_agent.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onTrackerChanged;

  const ProfileScreen({super.key, required this.userId, this.onTrackerChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();
  final TextEditingController _whatsappPhoneController =
      TextEditingController();

  String _bloodType = 'Unknown';
  final List<String> _medicalConditions = [];
  final List<String> _allergies = [];
  final List<String> _medications = [];
  String _trackerType = 'menstruation';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAnalyzing = false;
  UserProfile? _profile;
  Map<String, dynamic>? _ocrResult;

  // Modern color palette
  static const Color _primaryPurple = Color(0xFFD4C4E8);
  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _darkPurple = Color(0xFF9B7FC8);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _pinkAccent = Color(0xFFE8C4C4);

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
    'Diabetes',
    'Hypertension',
    'Asthma',
    'PCOS',
    'Thyroid',
    'Anemia',
    'Migraine',
    'Anxiety',
    'Depression',
  ];

  final List<String> _commonAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Dairy',
    'Eggs',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
    'Penicillin',
    'Latex',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await _apiService.getUserProfile(widget.userId);

      if (profileData != null && mounted) {
        final profile = UserProfile.fromJson(profileData);

        // Load phone number
        final phoneNumber = await _apiService.getPhoneNumber(widget.userId);

        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _ageController.text = profile.age.toString();
          _heightController.text = profile.height.toString();
          _weightController.text = profile.weight.toString();
          _bloodType = profile.bloodType;
          _medicalConditions.addAll(profile.medicalConditions);
          _allergies.addAll(profile.allergies);
          _medications.addAll(profile.medications);
          _emergencyContactController.text = profile.emergencyContact ?? '';
          _emergencyPhoneController.text = profile.emergencyPhone ?? '';
          _emergencyEmailController.text = profile.emergencyEmail ?? '';
          _whatsappPhoneController.text = phoneNumber ?? '';
          _trackerType = profile.trackerType;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final profile = UserProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bloodType: _bloodType,
        medicalConditions: _medicalConditions,
        allergies: _allergies,
        medications: _medications,
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        emergencyEmail: _emergencyEmailController.text.trim().isEmpty
            ? null
            : _emergencyEmailController.text.trim(),
        trackerType: _trackerType,
        createdAt: _profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _apiService.saveUserProfile(profile);

      // Save phone number if provided
      if (_whatsappPhoneController.text.trim().isNotEmpty) {
        await _apiService.updatePhoneNumber(
          widget.userId,
          _whatsappPhoneController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Profile saved successfully! 💜'
                  : 'Failed to save profile. Please try again.',
            ),
            backgroundColor: success ? _greenAccent : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) {
          setState(() {
            _profile = profile;
            _isSaving = false;
          });
        } else {
          setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving profile. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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
        title: Consumer<LocalizationProvider>(
          builder: (context, localization, _) {
            return Text(
              localization.getString('my_profile'),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black87),
              onPressed: _showSettingsDialog,
              tooltip: 'Settings',
            ),
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black87,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.black87),
              onPressed: _isSaving ? null : _saveProfile,
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _darkPurple))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_primaryPurple, _lightPurple],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryPurple.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: _darkPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Consumer<LocalizationProvider>(
                              builder: (context, localization, _) {
                                return Text(
                                  _nameController.text.isEmpty
                                      ? localization.getString('your_profile')
                                      : _nameController.text,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                            if (_profile != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'BMI: ${_profile!.bmi.toStringAsFixed(1)} (${_profile!.bmiCategory})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tracker Selection
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            localization.getString('active_tracker'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.swap_horiz,
                        iconColor: const Color(0xFF4CAF50),
                        children: [
                          Consumer<LocalizationProvider>(
                            builder: (context, localization, _) {
                              return Text(
                                localization.getString('current_tracker'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTrackerSelector(),
                          const SizedBox(height: 12),
                          Consumer<LocalizationProvider>(
                            builder: (context, localization, _) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        localization.getString(
                                          'changing_tracker_info',
                                        ),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Wallet & Vouchers Section
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            'Rewards & Vouchers',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WalletScreen(userId: widget.userId),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _primaryPurple,
                                      _primaryPurple.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryPurple.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.wallet,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'My Wallet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'View points',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VoucherScreen(userId: widget.userId),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _greenAccent,
                                      _greenAccent.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _greenAccent.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.card_giftcard,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Vouchers',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Redeem rewards',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Basic Information
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            localization.getString('basic_information'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
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
                            Consumer<LocalizationProvider>(
                              builder: (context, localization, _) {
                                return _buildTextField(
                                  controller: _nameController,
                                  label: localization.getString('full_name'),
                                  icon: Icons.badge,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localization.getString(
                                            'please_enter',
                                          ) +
                                          ' ' +
                                          localization.getString('full_name');
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Consumer<LocalizationProvider>(
                              builder: (context, localization, _) {
                                return _buildTextField(
                                  controller: _ageController,
                                  label: localization.getString('age'),
                                  icon: Icons.cake,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localization.getString(
                                            'please_enter',
                                          ) +
                                          ' ' +
                                          localization.getString('age');
                                    }
                                    final age = int.tryParse(value);
                                    if (age == null || age < 1 || age > 120) {
                                      return localization.getString(
                                        'invalid_age',
                                      );
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Physical Measurements
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
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _heightController,
                                    label: 'Height (cm)',
                                    icon: Icons.height,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final height = double.tryParse(value);
                                      if (height == null ||
                                          height < 50 ||
                                          height > 300) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _weightController,
                                    label: 'Weight (kg)',
                                    icon: Icons.monitor_weight,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final weight = double.tryParse(value);
                                      if (weight == null ||
                                          weight < 20 ||
                                          weight > 300) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Blood Type',
                              value: _bloodType,
                              items: _bloodTypes,
                              onChanged: (value) {
                                setState(() => _bloodType = value!);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Medical Information
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            localization.getString('medical_information'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.medical_services,
                        iconColor: _greenAccent,
                        children: [
                          _buildChipSection(
                            label: 'Medical Conditions',
                            items: _medicalConditions,
                            suggestions: _commonConditions,
                            color: _pinkAccent,
                            allowCustom: true,
                          ),
                          const SizedBox(height: 16),
                          _buildChipSection(
                            label: 'Allergies',
                            items: _allergies,
                            suggestions: _commonAllergies,
                            color: _greenAccent,
                            allowCustom: true,
                          ),
                          const SizedBox(height: 16),
                          _buildChipSection(
                            label: 'Current Medications',
                            items: _medications,
                            suggestions: [],
                            color: _primaryPurple,
                            allowCustom: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Medical Report OCR Analysis
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            localization.getString('medical_report_analysis'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.document_scanner,
                        iconColor: Colors.blue,
                        children: [
                          Consumer<LocalizationProvider>(
                            builder: (context, localization, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.getString(
                                      'upload_medical_report',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localization.getString(
                                      'upload_medical_report_desc',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isAnalyzing
                                  ? null
                                  : _uploadMedicalReport,
                              icon: _isAnalyzing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.image),
                              label: Text(
                                _isAnalyzing
                                    ? 'Analyzing...'
                                    : 'Upload Report Image',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (_ocrResult != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Analysis Result',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          setState(() => _ocrResult = null);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _ocrResult!['summary'] ??
                                        'No summary available',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                  if (_ocrResult!['keyFindings'] != null &&
                                      (_ocrResult!['keyFindings'] as List)
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Key Findings:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...((_ocrResult!['keyFindings'] as List)
                                        .cast<String>()
                                        .map(
                                          (finding) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '• ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    finding,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                  if (_ocrResult!['recommendations'] != null &&
                                      (_ocrResult!['recommendations'] as List)
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Recommendations:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...((_ocrResult!['recommendations'] as List)
                                        .cast<String>()
                                        .map(
                                          (rec) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '✓ ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    rec,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Emergency Contact
                      Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Text(
                            localization.getString('emergency_contact'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.emergency,
                        iconColor: Colors.red,
                        children: [
                          _buildTextField(
                            controller: _emergencyContactController,
                            label: 'Contact Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emergencyPhoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emergencyEmailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!value.contains('@')) {
                                  return 'Invalid email';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Emergency Button
                          if (_emergencyEmailController.text.isNotEmpty ||
                              _emergencyPhoneController.text.isNotEmpty)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF5252),
                                    Color(0xFFFF1744),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _sendEmergencyAlert,
                                icon: const Icon(Icons.warning_amber_rounded),
                                label: const Text(
                                  'Send Emergency Alert',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // WhatsApp Notifications
                      const Text(
                        'WhatsApp Notifications',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.message,
                        iconColor: Colors.green,
                        children: [
                          const Text(
                            'Phone Number for WhatsApp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your phone number to receive health reminders and personalized notifications via WhatsApp.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _whatsappPhoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!value.startsWith('+')) {
                                  return 'Phone must start with +';
                                }
                                if (value.length < 10 || value.length > 16) {
                                  return 'Invalid phone format';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Format: +[country code][number]\nExample: +1234567890',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // App Settings Section
                      const Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.settings,
                        iconColor: Colors.blue,
                        children: [
                          const Text(
                            'Reset & Restart',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Clear all app data and restart with fresh setup. This will log you out and reset all trackers.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout & Restart App'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showDeleteAccountDialog,
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Permanently Delete Account'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                side: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: _darkPurple),
        filled: true,
        fillColor: _lightPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
      onChanged: (value) {
        // Update BMI in real-time if height/weight changed
        if (controller == _heightController ||
            controller == _weightController) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.bloodtype, size: 20, color: _darkPurple),
        filled: true,
        fillColor: _lightPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> items,
    required List<String> suggestions,
    required Color color,
    bool allowCustom = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (allowCustom)
              TextButton.icon(
                onPressed: () => _showAddCustomDialog(label, items),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: _darkPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((item) {
              final isSelected = items.contains(item);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      items.remove(item);
                    } else {
                      items.add(item);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        if (items.isNotEmpty && suggestions.isEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() => items.remove(item));
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (items.isEmpty)
          Text(
            'No $label added',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  void _showAddCustomDialog(String label, List<String> items) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && !items.contains(value)) {
                setState(() => items.add(value));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerSelector() {
    return Column(
      children: [
        _buildTrackerOption(
          title: 'Pregnancy',
          icon: Icons.child_care,
          value: 'pregnancy',
          color: const Color(0xFFFFB6C1),
        ),
        const SizedBox(height: 8),
        _buildTrackerOption(
          title: 'Menstruation',
          icon: Icons.calendar_today,
          value: 'menstruation',
          color: const Color(0xFFBA68C8),
        ),
        const SizedBox(height: 8),
        _buildTrackerOption(
          title: 'Menopause',
          icon: Icons.favorite,
          value: 'menopause',
          color: const Color(0xFFFF8A80),
        ),
        const SizedBox(height: 16),
        // Educate Me Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EducationChatScreen(userId: widget.userId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4C4E8).withValues(alpha: 0.3),
                  const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4C4E8), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C4E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Educate Me',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Learn about periods, menopause & pregnancy',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFD4C4E8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Voice Chat Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgoraConversationalVoiceAgent(
                  userId: widget.userId,
                  agoraAppId: 'bb1ca613e3b94aa7af3eec189d172e99',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                  const Color(0xFFD4A5A5).withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA67C7C), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA67C7C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Chat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Talk with AI about your health',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFA67C7C),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerOption({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _trackerType == value;
    return GestureDetector(
      onTap: () async {
        if (isSelected) return; // Don't do anything if already selected

        final oldTracker = _trackerType;
        setState(() => _trackerType = value);

        // Save immediately when tracker changes
        await _saveProfile();

        // Notify parent to refresh and navigate back
        if (widget.onTrackerChanged != null && oldTracker != value && mounted) {
          // Show simple loading dialog while switching
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: color, strokeWidth: 4),
                    const SizedBox(height: 24),
                    Text(
                      'Switching to $title...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Trigger refresh - this will rebuild MainAppScreen with new tracker
          widget.onTrackerChanged!();

          // Wait for the rebuild to complete
          await Future.delayed(const Duration(milliseconds: 600));

          // Pop the loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Pop all screens back to home
          // Count how many times to pop (profile + any intermediate screens)
          if (mounted) {
            // Get the current navigator
            final navigator = Navigator.of(context);

            // Pop until we can't pop anymore (back to home screen)
            // But keep at least one route (the home screen from MainAppScreen)
            while (navigator.canPop() && mounted) {
              navigator.pop();
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Logout & Restart'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Clear all local app data'),
            Text('• Reset all trackers'),
            Text('• Return to tracker selection screen'),
            Text('• Require fresh setup'),
            SizedBox(height: 16),
            Text(
              'Your data on the server will be preserved. You can log back in anytime.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to continue?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout & Restart'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Wait a moment for effect
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Pop loading dialog
        Navigator.pop(context);

        // Navigate to login screen (replace all routes)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.deepOrange, size: 28),
            SizedBox(width: 12),
            Text('Delete Account'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ WARNING: This action cannot be undone!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Your entire user profile'),
            Text('• All health logs and data'),
            Text('• All cycle tracking history'),
            Text('• Wallet points and vouchers'),
            Text('• All personal information'),
            SizedBox(height: 16),
            Text(
              'This action is PERMANENT and IRREVERSIBLE. All your data will be completely removed from our servers.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.deepOrange,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting your account...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Call API to delete account
        final success = await _apiService.deleteUserAccount(widget.userId);

        if (mounted) {
          // Pop loading dialog
          Navigator.pop(context);

          if (success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Your account has been permanently deleted.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Clear user session
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            // Wait a moment for effect
            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              // Navigate to login screen (replace all routes)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Failed to delete account. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error deleting account: $e');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _sendEmergencyAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Emergency Alert'),
          ],
        ),
        content: Text(
          'This will send an emergency alert to:\n\n'
          '${_emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : "Emergency Contact"}\n'
          '${_emergencyPhoneController.text.isNotEmpty ? "📞 ${_emergencyPhoneController.text}\n" : ""}'
          '${_emergencyEmailController.text.isNotEmpty ? "📧 ${_emergencyEmailController.text}" : ""}\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Sending emergency alert...'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 10),
          ),
        );
      }

      // Send email via backend API
      bool emailSuccess = false;
      if (_emergencyEmailController.text.isNotEmpty) {
        try {
          emailSuccess = await _apiService.sendEmergencyAlert(
            userId: widget.userId,
            userProfile: {
              'name': _nameController.text,
              'age': int.tryParse(_ageController.text) ?? 0,
              'blood_type': _bloodType,
              'medical_conditions': _medicalConditions,
              'allergies': _allergies,
              'medications': _medications,
              'tracker_type': _trackerType,
            },
            emergencyContact: {
              'name': _emergencyContactController.text,
              'email': _emergencyEmailController.text,
              'phone': _emergencyPhoneController.text,
            },
          );
        } catch (e) {
          debugPrint('Error sending emergency email: $e');
        }
      }

      // Try to call if phone available
      bool phoneSuccess = false;
      if (_emergencyPhoneController.text.isNotEmpty) {
        final phoneUri = Uri(
          scheme: 'tel',
          path: _emergencyPhoneController.text,
        );

        try {
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
            phoneSuccess = true;
          }
        } catch (e) {
          debugPrint('Error launching phone: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              emailSuccess || phoneSuccess
                  ? '🚨 Emergency alert sent successfully!'
                  : 'Unable to send alert. Please check contact details.',
            ),
            backgroundColor: (emailSuccess || phoneSuccess)
                ? Colors.green
                : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _uploadMedicalReport() async {
    // Show options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Upload Medical Report'),
        content: const Text(
          'Choose how you want to upload your medical report:',
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickAndAnalyzeReport(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickAndAnalyzeReport(ImageSource.gallery);
            },
            icon: const Icon(Icons.image),
            label: const Text('Choose Image'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyzeReport(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() => _isAnalyzing = true);

      // Read image file and convert to base64
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to backend for OCR analysis
      final result = await _apiService.analyzeMedicalReport(
        userId: widget.userId,
        base64Image: base64Image,
        fileName: image.name,
        fileType: 'image',
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);

        if (result != null) {
          setState(() => _ocrResult = result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Medical report analyzed successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '❌ Failed to analyze report. Please try again.',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading medical report: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error uploading report. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showSettingsDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Consumer<LocalizationProvider>(
          builder: (context, localization, _) {
            return Text(localization.getString('app_settings'));
          },
        ),
        content: Consumer2<ThemeProvider, LocalizationProvider>(
          builder: (context, theme, localization, _) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Section
                  Text(
                    localization.getString('theme'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: Text(localization.getString('light_mode')),
                          value: ThemeMode.light,
                          groupValue: theme.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setTheme(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localization.getString('theme_changed'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(localization.getString('dark_mode')),
                          value: ThemeMode.dark,
                          groupValue: theme.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setTheme(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localization.getString('theme_changed'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Color Scheme Section
                  Text(
                    localization.getString('color_scheme'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<AppColorScheme>(
                          title: Text(localization.getString('color_purple')),
                          value: AppColorScheme.purple,
                          groupValue: theme.colorScheme,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setColorScheme(value);
                            }
                          },
                        ),
                        RadioListTile<AppColorScheme>(
                          title: Text(localization.getString('color_rose')),
                          value: AppColorScheme.rose,
                          groupValue: theme.colorScheme,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setColorScheme(value);
                            }
                          },
                        ),
                        RadioListTile<AppColorScheme>(
                          title: Text(localization.getString('color_teal')),
                          value: AppColorScheme.teal,
                          groupValue: theme.colorScheme,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setColorScheme(value);
                            }
                          },
                        ),
                        RadioListTile<AppColorScheme>(
                          title: Text(localization.getString('color_amber')),
                          value: AppColorScheme.amber,
                          groupValue: theme.colorScheme,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setColorScheme(value);
                            }
                          },
                        ),
                        RadioListTile<AppColorScheme>(
                          title: Text(localization.getString('color_indigo')),
                          value: AppColorScheme.indigo,
                          groupValue: theme.colorScheme,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setColorScheme(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Language Section
                  Text(
                    localization.getString('language'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(localization.getString('english')),
                          value: 'en',
                          groupValue: localization.language,
                          onChanged: (value) {
                            if (value != null) {
                              localizationProvider.setLanguage(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localization.getString('language_changed'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(localization.getString('hindi')),
                          value: 'hi',
                          groupValue: localization.language,
                          onChanged: (value) {
                            if (value != null) {
                              localizationProvider.setLanguage(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localization.getString('language_changed'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LocalizationProvider>(
              builder: (context, localization, _) {
                return Text(localization.getString('ok'));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyEmailController.dispose();
    _whatsappPhoneController.dispose();
    super.dispose();
  }
}
