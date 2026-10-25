import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class PCOSLogScreen extends StatefulWidget {
  final String userId;

  const PCOSLogScreen({super.key, required this.userId});

  @override
  State<PCOSLogScreen> createState() => _PCOSLogScreenState();
}

class _PCOSLogScreenState extends State<PCOSLogScreen> {
  final ApiService _apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  String _flowLevel = 'Medium';
  final List<String> _selectedMoods = [];
  final List<String> _selectedSymptoms = [];
  bool _isSaving = false;
  int _currentCycleDay = 1;

  // PCOS-specific tracking
  int _acneSeverity = 0;
  bool _hairLoss = false;
  bool _facialHair = false;
  bool _bodyHair = false;
  double? _weightChange;
  int _energyLevel = 3;
  int _sleepQuality = 3;
  int _stressLevel = 3;
  final List<String> _selectedCravings = [];

  // Exercise tracking
  int _exerciseMinutes = 0;
  String _exerciseType = 'None';

  // Nutrition tracking
  int _waterIntake = 0;
  bool _hadProteinBreakfast = false;
  bool _hadLowGIMeals = false;
  int _vegetableServings = 0;

  // Soft, calming colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenMood = Color(0xFFB8D4C8);
  static const Color _purpleMood = Color(0xFFD4C4E8);
  static const Color _blueAccent = Color(0xFFA8D8EA);

  final List<String> _flowLevels = [
    'Light',
    'Medium',
    'Heavy',
    'Spotting',
    'None',
  ];
  final List<String> _moods = [
    'Happy',
    'Sad',
    'Anxious',
    'Irritable',
    'Calm',
    'Energetic',
    'Tired',
  ];
  final List<String> _symptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Back Pain',
    'Breast Tenderness',
    'Mood Swings',
    'Nausea',
  ];
  final List<String> _cravings = [
    'Sweet',
    'Salty',
    'Carbs',
    'Chocolate',
    'Fried Food',
  ];
  final List<String> _exerciseTypes = [
    'None',
    'Walking',
    'Running',
    'Yoga',
    'Strength Training',
    'HIIT',
    'Cycling',
    'Swimming',
    'Dancing',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCycleDay();
    });
  }

  Future<void> _loadCycleDay() async {
    try {
      final predictions = await _apiService.getMenstruationPredictions(
        widget.userId,
      );

      if (predictions != null && predictions['last_period_start'] != null) {
        final lastPeriod = DateTime.parse(predictions['last_period_start']);
        final today = DateTime.now();
        final cycleDay = today.difference(lastPeriod).inDays + 1;

        if (mounted) {
          setState(() {
            _currentCycleDay = cycleDay;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading cycle day: $e');
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
          'PCOS Daily Log',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Card
            _buildDateCard(),
            const SizedBox(height: 24),

            // Period Tracking Section
            _buildSectionHeader('Period Tracking', Icons.water_drop),
            const SizedBox(height: 12),
            _buildFlowCard(),
            const SizedBox(height: 12),
            _buildMoodCard(),
            const SizedBox(height: 12),
            _buildSymptomsCard(),

            const SizedBox(height: 24),

            // PCOS Symptoms Section
            _buildSectionHeader('PCOS Symptoms', Icons.favorite),
            const SizedBox(height: 12),
            _buildPCOSSymptomsCard(),
            const SizedBox(height: 12),
            _buildEnergyLevelsCard(),
            const SizedBox(height: 12),
            _buildCravingsCard(),

            const SizedBox(height: 24),

            // Exercise Section
            _buildSectionHeader('Exercise & Movement', Icons.fitness_center),
            const SizedBox(height: 12),
            _buildExerciseCard(),

            const SizedBox(height: 24),

            // Nutrition Section
            _buildSectionHeader('Nutrition & Diet', Icons.restaurant),
            const SizedBox(height: 12),
            _buildNutritionCard(),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _purpleMood.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _purpleMood, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryPink.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: _darkPink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: _darkPink),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: _darkPink,
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlowCard() {
    return _buildCard(
      icon: Icons.water_drop,
      iconColor: _primaryPink,
      title: 'Flow Level',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _flowLevels.map((level) {
          final isSelected = _flowLevel == level;
          return _buildChip(level, isSelected, _primaryPink, () {
            setState(() => _flowLevel = level);
          });
        }).toList(),
      ),
    );
  }

  Widget _buildMoodCard() {
    return _buildCard(
      icon: Icons.mood,
      iconColor: _greenMood,
      title: 'Mood',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _moods.map((mood) {
          final isSelected = _selectedMoods.contains(mood);
          return _buildChip(mood, isSelected, _greenMood, () {
            setState(() {
              if (isSelected) {
                _selectedMoods.remove(mood);
              } else {
                _selectedMoods.add(mood);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return _buildCard(
      icon: Icons.healing,
      iconColor: _purpleMood,
      title: 'Symptoms',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _symptoms.map((symptom) {
          final isSelected = _selectedSymptoms.contains(symptom);
          return _buildChip(symptom, isSelected, _purpleMood, () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildPCOSSymptomsCard() {
    return _buildCard(
      icon: Icons.favorite,
      iconColor: Colors.red.shade300,
      title: 'PCOS-Specific Symptoms',
      child: Column(
        children: [
          _buildSlider(
            'Acne Severity',
            _acneSeverity,
            0,
            5,
            (value) => setState(() => _acneSeverity = value.round()),
          ),
          const SizedBox(height: 16),
          _buildCheckbox('Hair Loss', _hairLoss, (value) {
            setState(() => _hairLoss = value!);
          }),
          _buildCheckbox('Facial Hair', _facialHair, (value) {
            setState(() => _facialHair = value!);
          }),
          _buildCheckbox('Body Hair', _bodyHair, (value) {
            setState(() => _bodyHair = value!);
          }),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Weight Change (kg)',
              hintText: 'e.g., +0.5 or -1.0',
              filled: true,
              fillColor: _lightPink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            onChanged: (value) {
              setState(() => _weightChange = double.tryParse(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyLevelsCard() {
    return _buildCard(
      icon: Icons.battery_charging_full,
      iconColor: _blueAccent,
      title: 'Energy & Wellness',
      child: Column(
        children: [
          _buildSlider(
            'Energy Level',
            _energyLevel,
            1,
            5,
            (value) => setState(() => _energyLevel = value.round()),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Sleep Quality',
            _sleepQuality,
            1,
            5,
            (value) => setState(() => _sleepQuality = value.round()),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Stress Level',
            _stressLevel,
            1,
            5,
            (value) => setState(() => _stressLevel = value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildCravingsCard() {
    return _buildCard(
      icon: Icons.fastfood,
      iconColor: Colors.orange.shade300,
      title: 'Cravings',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _cravings.map((craving) {
          final isSelected = _selectedCravings.contains(craving);
          return _buildChip(craving, isSelected, Colors.orange.shade300, () {
            setState(() {
              if (isSelected) {
                _selectedCravings.remove(craving);
              } else {
                _selectedCravings.add(craving);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseCard() {
    return _buildCard(
      icon: Icons.fitness_center,
      iconColor: _greenMood,
      title: 'Today\'s Exercise',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _exerciseType,
            decoration: InputDecoration(
              labelText: 'Exercise Type',
              filled: true,
              fillColor: _lightPink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _exerciseTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() => _exerciseType = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Duration (minutes)',
              hintText: 'e.g., 30',
              filled: true,
              fillColor: _lightPink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _exerciseMinutes = int.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _greenMood.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: _greenMood),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Target: 150-300 min/week moderate exercise',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return _buildCard(
      icon: Icons.restaurant,
      iconColor: Colors.green.shade400,
      title: 'Nutrition & Diet',
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Water Intake (glasses)',
              hintText: 'e.g., 8',
              filled: true,
              fillColor: _lightPink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _waterIntake = int.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Vegetable Servings',
              hintText: 'e.g., 5',
              filled: true,
              fillColor: _lightPink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _vegetableServings = int.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 16),
          _buildCheckbox('Had Protein-Rich Breakfast', _hadProteinBreakfast, (
            value,
          ) {
            setState(() => _hadProteinBreakfast = value!);
          }),
          _buildCheckbox('Followed Low-GI Meals', _hadLowGIMeals, (value) {
            setState(() => _hadLowGIMeals = value!);
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Focus: Low-GI carbs, high protein, healthy fats',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '$value/${max}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _darkPink,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: _darkPink,
          inactiveColor: _lightPink,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: _darkPink,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveLog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _darkPink.withValues(alpha: 0.5),
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
                'Save PCOS Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _saveLog() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final log = {
        'user_id': widget.userId,
        'date': _selectedDate.toIso8601String(),
        'cycle_day': _currentCycleDay,
        'flow_level': _flowLevel,
        'mood': _selectedMoods.join(', '),
        'symptoms': _selectedSymptoms,
        // PCOS-specific
        'acne_severity': _acneSeverity,
        'hair_loss': _hairLoss,
        'facial_hair': _facialHair,
        'body_hair': _bodyHair,
        'weight_change': _weightChange,
        'energy_level': _energyLevel,
        'sleep_quality': _sleepQuality,
        'stress_level': _stressLevel,
        'cravings': _selectedCravings,
        // Exercise
        'exercise_minutes': _exerciseMinutes,
        'exercise_type': _exerciseType,
        // Nutrition
        'water_intake': _waterIntake,
        'vegetable_servings': _vegetableServings,
        'protein_breakfast': _hadProteinBreakfast,
        'low_gi_meals': _hadLowGIMeals,
        'notes': '',
      };

      final success = await _apiService.addMenstruationLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ PCOS log saved successfully!'
                  : '❌ Failed to save log. Please try again.',
            ),
            backgroundColor: success ? _greenMood : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
