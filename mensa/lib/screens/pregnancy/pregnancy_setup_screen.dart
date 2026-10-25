import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../dashboard_screen.dart';
import '../profile_screen.dart';

class PregnancySetupScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onSetupComplete;
  final VoidCallback? onTrackerChanged;

  const PregnancySetupScreen({
    super.key,
    required this.userId,
    required this.onSetupComplete,
    this.onTrackerChanged,
  });

  @override
  State<PregnancySetupScreen> createState() => _PregnancySetupScreenState();
}

class _PregnancySetupScreenState extends State<PregnancySetupScreen> {
  final ApiService _apiService = ApiService();
  DateTime? _selectedDueDate;
  DateTime? _selectedLMP;
  bool _isLoading = false;
  int _setupStep = 1; // Start directly at method selection (skip welcome)

  // Modern mint/teal color palette
  static const Color _primaryMint = Color(0xFF98D8C8);
  static const Color _lightMint = Color(0xFFF0FFF8);
  static const Color _darkMint = Color(0xFF66A896);
  static const Color _backgroundColor = Color(0xFFF5FFF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            // Open profile screen to allow tracker change
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: widget.userId,
                  onTrackerChanged: widget.onTrackerChanged,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Pregnancy Setup',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildStepContent()),
    );
  }

  Widget _buildStepContent() {
    switch (_setupStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildMethodSelectionStep();
      case 2:
        return _buildDateInputStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryMint, _lightMint],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryMint.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pregnant_woman,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to\nPregnancy Tracker! 🤰',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Let\'s set up your pregnancy journey.\nWe\'ll track your progress week by week!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_primaryMint, _darkMint]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _primaryMint.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _setupStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelectionStep() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Text(
                'How would you like\nto track?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your preferred method',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildMethodCard(
                'Due Date',
                'I know my due date',
                Icons.calendar_today,
                () {
                  setState(() {
                    _setupStep = 2;
                    _selectedLMP = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildMethodCard(
                'Last Menstrual Period',
                'I know my last period date',
                Icons.event,
                () {
                  setState(() {
                    _setupStep = 2;
                    _selectedDueDate = null;
                  });
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _setupStep = 0;
              });
            },
            icon: Icon(Icons.arrow_back, color: _darkMint),
            label: Text('Back', style: TextStyle(color: _darkMint)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryMint.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_primaryMint, _darkMint]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: _primaryMint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputStep() {
    final isUsingDueDate = _selectedLMP == null;
    final selectedDate = isUsingDueDate ? _selectedDueDate : _selectedLMP;

    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                isUsingDueDate
                    ? 'When is your\ndue date?'
                    : 'When was your\nlast period?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isUsingDueDate
                    ? 'Select your expected delivery date'
                    : 'Select the first day of your last period',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryMint, _lightMint],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUsingDueDate ? Icons.calendar_today : Icons.event,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : 'No date selected',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: selectedDate != null
                        ? Colors.black87
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryMint, _darkMint],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryMint.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Choose Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (selectedDate != null)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryMint, _darkMint],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryMint.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Start Tracking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _setupStep = 1;
                    _selectedDueDate = null;
                    _selectedLMP = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: _darkMint),
                label: Text('Back', style: TextStyle(color: _darkMint)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final isUsingDueDate = _selectedLMP == null;
    final initialDate = isUsingDueDate
        ? (_selectedDueDate ?? DateTime.now().add(const Duration(days: 280)))
        : (_selectedLMP ?? DateTime.now().subtract(const Duration(days: 14)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryMint,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isUsingDueDate) {
          _selectedDueDate = picked;
        } else {
          _selectedLMP = picked;
        }
      });
    }
  }

  Future<void> _createProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime dueDate;
      DateTime lmp;

      if (_selectedDueDate != null) {
        dueDate = _selectedDueDate!;
        lmp = dueDate.subtract(const Duration(days: 280));
      } else {
        lmp = _selectedLMP!;
        dueDate = lmp.add(const Duration(days: 280));
      }

      final success = await _apiService.createPregnancyProfile(
        widget.userId,
        lmp,
        dueDate,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile created successfully! 🎉'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate directly to dashboard with callback
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userId: widget.userId,
                onTrackerChanged: widget.onTrackerChanged,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
