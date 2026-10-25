import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_pregnancy.dart';
import '../models/food_item.dart';

class NutritionScreen extends StatefulWidget {
  final String userId;
  final UserPregnancy profile;

  const NutritionScreen({
    super.key,
    required this.userId,
    required this.profile,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<FoodItem> _foods = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  int _waterGlasses = 0;
  final Map<String, bool> _expandedFoods = {};

  // Modern color palette
  static const Color _primaryGreen = Color(0xFF98D8C8);
  static const Color _lightGreen = Color(0xFFF0FFF4);
  static const Color _accentGreen = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF66A896);
  static const Color _backgroundColor = Color(0xFFF5FFF8);
  static const Color _warningYellow = Color(0xFFFFF3CD);
  static const Color _dangerRed = Color(0xFFFF5252);
  static const Color _blueAccent = Color(0xFF64B5F6);
  static const Color _orangeAccent = Color(0xFFFFB74D);
  static const Color _purpleAccent = Color(0xFFBA68C8);

  final List<String> _categories = [
    'All',
    'Protein',
    'Calcium',
    'Iron',
    'Folate',
    'Omega-3',
    'Fiber',
  ];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/foods.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        _foods = data.map((json) => FoodItem.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimester = widget.profile.trimester;
    final safeFoods = _foods
        .where((f) => f.isSafeFor(widget.profile.allergies))
        .toList();
    final unsafeFoods = _foods
        .where((f) => !f.isSafeFor(widget.profile.allergies))
        .toList();

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
          'Nutrition Guide',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accentGreen))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trimester Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_primaryGreen, _lightGreen],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            size: 48,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Trimester $trimester',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getTrimesterAdvice(trimester),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Daily Nutrition Goals
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _orangeAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.track_changes,
                                  color: _orangeAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Daily Nutrition Goals',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildNutrientGoal(
                            'Protein',
                            '75-100g',
                            0.7,
                            _primaryGreen,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientGoal(
                            'Calcium',
                            '1000mg',
                            0.6,
                            _primaryGreen,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientGoal(
                            'Iron',
                            '27mg',
                            0.5,
                            _primaryGreen,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientGoal(
                            'Folate',
                            '600mcg',
                            0.8,
                            _primaryGreen,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Hydration Tracker
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _blueAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: _blueAccent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Hydration Today',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$_waterGlasses/8 glasses',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(8, (index) {
                              final isFilled = index < _waterGlasses;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isFilled &&
                                        index == _waterGlasses - 1) {
                                      _waterGlasses--;
                                    } else if (!isFilled &&
                                        index == _waterGlasses) {
                                      _waterGlasses++;
                                    }
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isFilled
                                        ? _blueAccent
                                        : _blueAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.water_drop,
                                    color: isFilled
                                        ? Colors.white
                                        : _blueAccent.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to track your water intake. Aim for 8 glasses daily!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Key Nutrients Info
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _purpleAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: _purpleAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Why These Nutrients Matter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildNutrientInfo(
                            'Folate',
                            'Prevents neural tube defects and supports baby\'s brain development',
                            Icons.psychology,
                            _purpleAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientInfo(
                            'Iron',
                            'Prevents anemia and supports increased blood volume',
                            Icons.favorite,
                            _dangerRed,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientInfo(
                            'Calcium',
                            'Builds baby\'s bones and teeth, maintains your bone health',
                            Icons.accessibility_new,
                            _blueAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientInfo(
                            'Protein',
                            'Essential for baby\'s growth and tissue development',
                            Icons.fitness_center,
                            _accentGreen,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = category);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _accentGreen
                                    : _accentGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Allergies Warning
                    if (widget.profile.allergies.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: _warningYellow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFFF9800,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF9800,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.warning_amber,
                                color: Color(0xFFFF9800),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Allergies',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.profile.allergies.join(", "),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Safe Foods Section
                    const Text(
                      'Recommended Foods',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _getFilteredFoods(safeFoods).length,
                      itemBuilder: (context, index) {
                        final food = _getFilteredFoods(safeFoods)[index];
                        final isExpanded = _expandedFoods[food.name] ?? false;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedFoods[food.name] = !isExpanded;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _accentGreen.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _getFoodIcon(food.name),
                                          color: _accentGreen,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              food.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: food.nutrients.map((
                                                nutrient,
                                              ) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getNutrientColor(
                                                      nutrient,
                                                    ).withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    nutrient,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _getNutrientColor(
                                                        nutrient,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _lightGreen,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Benefits:',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _getFoodBenefits(food.name),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Serving Suggestion:',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _getServingSuggestion(food.name),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              height: 1.4,
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
                      },
                    ),

                    // Foods to Avoid Section
                    if (unsafeFoods.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Foods to Avoid',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: unsafeFoods.length,
                        itemBuilder: (context, index) {
                          final food = unsafeFoods[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _dangerRed.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _dangerRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.block,
                                      color: _dangerRed,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _dangerRed.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '⚠ Contains: ${food.avoidIfAllergic.join(", ")}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: _dangerRed,
                                              fontWeight: FontWeight.bold,
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
                        },
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  String _getTrimesterAdvice(int trimester) {
    switch (trimester) {
      case 1:
        return 'Focus on folic acid, iron, and protein. Eat small frequent meals to manage nausea.';
      case 2:
        return 'Increase calcium and vitamin D intake. Your baby\'s bones are developing rapidly.';
      case 3:
        return 'Boost iron and protein. Stay hydrated and eat fiber-rich foods to prevent constipation.';
      default:
        return 'Maintain a balanced diet with plenty of nutrients.';
    }
  }

  Widget _buildNutrientGoal(
    String name,
    String target,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              target,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientInfo(
    String name,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<FoodItem> _getFilteredFoods(List<FoodItem> foods) {
    if (_selectedCategory == 'All') return foods;
    return foods.where((food) {
      return food.nutrients.any(
        (nutrient) =>
            nutrient.toLowerCase().contains(_selectedCategory.toLowerCase()),
      );
    }).toList();
  }

  Color _getNutrientColor(String nutrient) {
    final lower = nutrient.toLowerCase();
    if (lower.contains('protein')) return _accentGreen;
    if (lower.contains('calcium')) return _blueAccent;
    if (lower.contains('iron')) return _dangerRed;
    if (lower.contains('folate') || lower.contains('folic'))
      return _purpleAccent;
    if (lower.contains('omega')) return _orangeAccent;
    return _darkGreen;
  }

  IconData _getFoodIcon(String foodName) {
    final lower = foodName.toLowerCase();
    if (lower.contains('milk') ||
        lower.contains('yogurt') ||
        lower.contains('cheese')) {
      return Icons.local_drink;
    }
    if (lower.contains('egg')) return Icons.egg;
    if (lower.contains('fish') || lower.contains('salmon'))
      return Icons.set_meal;
    if (lower.contains('spinach') || lower.contains('broccoli'))
      return Icons.eco;
    if (lower.contains('lentil') || lower.contains('oat')) return Icons.grain;
    if (lower.contains('almond') || lower.contains('nut')) return Icons.nature;
    if (lower.contains('potato') || lower.contains('avocado')) return Icons.spa;
    if (lower.contains('berr')) return Icons.local_florist;
    if (lower.contains('chicken')) return Icons.restaurant;
    if (lower.contains('bread')) return Icons.bakery_dining;
    return Icons.restaurant_menu;
  }

  String _getFoodBenefits(String foodName) {
    final benefits = {
      'Milk':
          'Excellent source of calcium for strong bones and teeth. Provides high-quality protein for tissue growth.',
      'Yogurt':
          'Contains probiotics for digestive health. Rich in calcium and protein for baby\'s development.',
      'Eggs':
          'Complete protein source with all essential amino acids. Choline supports brain development.',
      'Salmon':
          'Omega-3 fatty acids support baby\'s brain and eye development. High-quality protein source.',
      'Spinach':
          'Iron prevents anemia. Folate crucial for neural tube development. Rich in vitamins A and C.',
      'Lentils':
          'Plant-based protein and iron. High in folate for baby\'s development. Excellent fiber source.',
      'Oats':
          'Provides sustained energy. Rich in B vitamins and iron. Helps manage blood sugar levels.',
      'Almonds':
          'Healthy fats support baby\'s brain development. Vitamin E protects cells. Good magnesium source.',
      'Sweet Potato':
          'Beta-carotene converts to vitamin A for vision and immune function. High in fiber.',
      'Berries':
          'Antioxidants protect cells. Vitamin C aids iron absorption. Low glycemic index.',
      'Avocado':
          'Healthy fats for brain development. Folate for neural tube health. Potassium regulates blood pressure.',
      'Chicken':
          'Lean protein for tissue growth. B vitamins for energy metabolism. Iron for blood health.',
      'Cheese':
          'Concentrated calcium source. Protein for growth. Vitamin B12 for nerve function.',
      'Broccoli':
          'Vitamin C boosts immunity. Folate for development. Calcium for bones.',
      'Whole Grain Bread':
          'Complex carbs for energy. B vitamins for metabolism. Fiber aids digestion.',
    };
    return benefits[foodName] ??
        'Nutritious food that supports healthy pregnancy.';
  }

  String _getServingSuggestion(String foodName) {
    final suggestions = {
      'Milk': '3 cups daily. Try warm milk before bed or in smoothies.',
      'Yogurt': '1-2 cups daily. Add berries and nuts for a complete snack.',
      'Eggs': '1-2 eggs daily. Scrambled, boiled, or in omelets with veggies.',
      'Salmon': '2-3 servings weekly. Grilled, baked, or in salads.',
      'Spinach': '1-2 cups daily. In salads, smoothies, or cooked dishes.',
      'Lentils':
          '1 cup cooked, 3-4 times weekly. In soups, curries, or salads.',
      'Oats': '1/2 cup daily. As oatmeal, in smoothies, or baked goods.',
      'Almonds': '1/4 cup (handful) daily. As snack or in trail mix.',
      'Sweet Potato': '1 medium, 3-4 times weekly. Baked, mashed, or roasted.',
      'Berries': '1 cup daily. Fresh, in smoothies, or with yogurt.',
      'Avocado': '1/2 avocado daily. On toast, in salads, or as guacamole.',
      'Chicken': '3-4 oz, 3-4 times weekly. Grilled, baked, or in stir-fries.',
      'Cheese': '1-2 oz daily. In sandwiches, salads, or as snack.',
      'Broccoli':
          '1 cup, 3-4 times weekly. Steamed, roasted, or in stir-fries.',
      'Whole Grain Bread': '2-3 slices daily. For sandwiches or with meals.',
    };
    return suggestions[foodName] ?? 'Include as part of a balanced diet.';
  }
}
