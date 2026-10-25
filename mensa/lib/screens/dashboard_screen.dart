import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_pregnancy.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../services/date_calculator_service.dart';
import '../widgets/streak_widget.dart';
import 'wallet_screen.dart';
import 'voucher_screen.dart';
import 'daily_log_screen.dart';
import 'nutrition_screen.dart';
import 'checklist_screen.dart';
import 'ai_chat_screen.dart';
import 'breathing_game_screen.dart';
import 'weekly_progress_screen.dart';
import 'profile_screen.dart';
import 'appointments_screen.dart';
import 'pregnancy_history_screen.dart';
import 'pregnancy_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onTrackerChanged;

  const DashboardScreen({
    super.key,
    required this.userId,
    this.onTrackerChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  UserPregnancy? _profile;
  List<Appointment> _upcomingAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAppointments();
  }

  Future<void> _loadProfile() async {
    final profile = await _apiService.getPregnancyProfile(widget.userId);
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _loadAppointments() async {
    try {
      final appointmentsData = await _apiService.getAppointments(widget.userId);
      final appointments = appointmentsData
          .map((data) => Appointment.fromJson(data))
          .toList();

      setState(() {
        _upcomingAppointments = appointments
            .where((a) => a.isUpcoming && !a.completed)
            .take(3)
            .toList();
        _upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      });
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }
  }

  // Soft, calming colors matching menstruation screen
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _purpleAccent = Color(0xFFD4C4E8);
  static const Color _yellowAccent = Color(0xFFF7E8C8);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _accentPink)),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: _darkPink),
              const SizedBox(height: 16),
              const Text(
                'Unable to load profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentWeek = _profile!.currentWeek;
    final trimester = _profile!.trimester;
    final daysUntilDue = DateCalculatorService.daysUntilDueDate(
      _profile!.dueDate,
    );

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
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
          'Pregnancy Tracker',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Wallet Button
          IconButton(
            icon: const Icon(Icons.wallet, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletScreen(userId: widget.userId),
                ),
              );
            },
            tooltip: 'Wallet',
          ),
          // Voucher Button
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherScreen(userId: widget.userId),
                ),
              );
            },
            tooltip: 'Vouchers',
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PregnancyHistoryScreen(userId: widget.userId),
                ),
              );
            },
            tooltip: 'View History',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentPink, _accentPink.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _accentPink.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PregnancyReportScreen(userId: widget.userId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Widget
              StreakWidget(
                userId: widget.userId,
                category: 'pregnancy',
                onStreakUpdated: () {
                  setState(() {});
                },
              ),

              const SizedBox(height: 24),

              // Main Pregnancy Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryPink, _lightPink],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPink.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Week $currentWeek',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateCalculatorService.getTrimesterName(trimester),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(
                          'Due Date',
                          '$daysUntilDue days',
                          Icons.calendar_today,
                        ),
                        _buildStatChip(
                          'Trimester',
                          '$trimester of 3',
                          Icons.pregnant_woman,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Grid
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Daily Log',
                      Icons.edit_note,
                      _purpleAccent,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DailyLogScreen(userId: widget.userId),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Weekly Progress',
                      Icons.calendar_month,
                      _primaryPink,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeeklyProgressScreen(
                            userId: widget.userId,
                            currentWeek: currentWeek,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Nutrition',
                      Icons.restaurant,
                      _greenAccent,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionScreen(
                            userId: widget.userId,
                            profile: _profile!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Checklist',
                      Icons.checklist,
                      _yellowAccent,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChecklistScreen(
                            userId: widget.userId,
                            currentWeek: currentWeek,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Appointments',
                      Icons.calendar_today,
                      _yellowAccent,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentsScreen(userId: widget.userId),
                        ),
                      ).then((_) => _loadAppointments()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'AI Assistant',
                      Icons.chat_bubble_outline,
                      _accentPink,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AIChatScreen(
                            userId: widget.userId,
                            currentWeek: currentWeek,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Breathing',
                      Icons.spa,
                      _lightPink,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BreathingGameScreen(userId: widget.userId),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'Voice AI',
                      Icons.mic,
                      const Color(0xFFB8D4C8),
                      () async {
                        final url = Uri.parse('https://10.0.2.2:3002/');
                        try {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open Voice AI. Please make sure the server is running.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Upcoming Appointments Section
              if (_upcomingAppointments.isNotEmpty) ...[
                const Text(
                  'Upcoming Appointments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ..._upcomingAppointments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final appointment = entry.value;

                  // Color progression from darker to lighter
                  final colors = [
                    _accentPink,
                    _accentPink.withValues(alpha: 0.7),
                    _accentPink.withValues(alpha: 0.4),
                  ];
                  final dotColor = colors[index.clamp(0, 2)];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Timeline dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Appointment text
                        Expanded(
                          child: Text(
                            '${appointment.title} - ${appointment.formattedTime}, ${appointment.formattedDate}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: _darkPink, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
