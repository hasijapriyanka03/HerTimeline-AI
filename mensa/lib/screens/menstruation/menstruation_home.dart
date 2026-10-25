import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/streak_widget.dart';
import '../../screens/wallet_screen.dart';
import '../../screens/voucher_screen.dart';
import 'cycle_history_screen.dart';
import 'menstruation_ai_chat_screen.dart';
import 'cycle_setup_screen.dart';
import 'pcos_log_screen.dart';
import 'menstruation_report_screen.dart';
import '../profile_screen.dart';
import '../agora_conversational_voice_agent.dart';

class MenstruationHome extends StatefulWidget {
  final String userId;
  final VoidCallback? onTrackerChanged;

  const MenstruationHome({
    super.key,
    required this.userId,
    this.onTrackerChanged,
  });

  @override
  State<MenstruationHome> createState() => _MenstruationHomeState();
}

class _MenstruationHomeState extends State<MenstruationHome> {
  String _flowLevel = 'Medium';
  final List<String> _selectedMoods = [];
  final List<String> _selectedSymptoms = [];

  // Real data from backend
  Map<String, dynamic>? _predictions;
  int _currentCycleDay = 1;
  String _currentPhase = 'Menstrual Phase';
  bool _isLoading = true;
  bool _needsSetup = false;

  // Soft, calming colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenMood = Color(0xFFB8D4C8);
  static const Color _purpleMood = Color(0xFFD4C4E8);

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
    'Acne',
    'Nausea',
  ];

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      // First check if any logs exist
      final logs = await apiService.getMenstruationLogs(widget.userId);

      if (logs.isEmpty) {
        // No logs at all - needs setup
        setState(() {
          _needsSetup = true;
          _isLoading = false;
        });
        return;
      }

      // Has logs, now check for predictions
      final predictions = await apiService.getMenstruationPredictions(
        widget.userId,
      );

      if (predictions != null &&
          predictions['last_period_start'] != null &&
          mounted) {
        setState(() {
          _predictions = predictions;
          _currentCycleDay = _calculateCurrentCycleDay(predictions);
          _currentPhase = _getCyclePhase(_currentCycleDay);
          _isLoading = false;
          _needsSetup = false;
        });
      } else if (logs.isNotEmpty && mounted) {
        // Has logs but no predictions yet - calculate from most recent log
        // Sort logs by date to find the most recent period start
        logs.sort((a, b) {
          final dateA = DateTime.parse(a['date'] ?? a['created_at']);
          final dateB = DateTime.parse(b['date'] ?? b['created_at']);
          return dateB.compareTo(dateA);
        });

        final mostRecentLog = logs.first;
        final lastPeriodDate = DateTime.parse(
          mostRecentLog['date'] ?? mostRecentLog['created_at'],
        );
        final today = DateTime.now();
        final daysSince = today.difference(lastPeriodDate).inDays;
        final cycleDay = daysSince + 1;

        // Get average cycle length from logs if available
        int avgCycleLength = 28;
        if (mostRecentLog['cycle_length'] != null) {
          avgCycleLength = mostRecentLog['cycle_length'] as int;
        }

        // Calculate next period
        final nextPeriod = lastPeriodDate.add(Duration(days: avgCycleLength));
        final daysUntilNext = nextPeriod.difference(today).inDays;

        setState(() {
          _predictions = {
            'last_period_start': lastPeriodDate.toIso8601String(),
            'predicted_next_period': nextPeriod.toIso8601String(),
            'average_cycle_length': avgCycleLength,
          };
          _currentCycleDay = cycleDay;
          _currentPhase = _getCyclePhase(cycleDay);
          _isLoading = false;
          _needsSetup = false;
        });

        debugPrint(
          '📊 Calculated from logs: Day $cycleDay, Next period in $daysUntilNext days',
        );
      } else {
        // Fallback to default state
        setState(() {
          _predictions = null;
          _currentCycleDay = 1;
          _currentPhase = 'Menstrual Phase';
          _isLoading = false;
          _needsSetup = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading predictions: $e');
      setState(() {
        _isLoading = false;
        _needsSetup = true;
      });
    }
  }

  int _calculateCurrentCycleDay(Map<String, dynamic> predictions) {
    if (predictions['last_period_start'] == null) {
      debugPrint('⚠️ No last_period_start in predictions');
      return 1;
    }

    try {
      final lastPeriod = DateTime.parse(predictions['last_period_start']);
      final today = DateTime.now();
      final daysSinceLastPeriod = today.difference(lastPeriod).inDays;

      debugPrint('✅ Calculated cycle day: ${daysSinceLastPeriod + 1}');
      return daysSinceLastPeriod + 1;
    } catch (e) {
      debugPrint('❌ Error calculating cycle day: $e');
      return 1;
    }
  }

  String _getCyclePhase(int day) {
    if (day <= 5) return 'Menstrual Phase';
    if (day <= 13) return 'Follicular Phase';
    if (day <= 16) return 'Ovulation Phase';
    return 'Luteal Phase';
  }

  String _getDaysUntilNextPeriod() {
    if (_predictions == null ||
        _predictions!['predicted_next_period'] == null) {
      return '-- days';
    }

    final nextPeriod = DateTime.parse(_predictions!['predicted_next_period']);
    final today = DateTime.now();
    final daysUntil = nextPeriod.difference(today).inDays;

    if (daysUntil < 0) return 'Overdue';
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return '$daysUntil days';
  }

  Future<void> _sendPersonalizedNotification() async {
    try {
      final apiService = ApiService();

      // Get user's recent logs to personalize the message
      final logs = await apiService.getMenstruationLogs(widget.userId);

      String title = '💜 Health Reminder';
      String body = 'Keep tracking your health!';

      if (logs.isNotEmpty) {
        // Call backend to generate personalized notification using Gemini
        final response = await apiService.generatePersonalizedNotification(
          userId: widget.userId,
          tracker: 'menstruation',
          cycleDay: _currentCycleDay,
        );

        if (response != null) {
          title = response['title'] ?? title;
          body = response['body'] ?? body;
        }
      }

      // Get phone number for WhatsApp
      final phoneNumber = await apiService.getPhoneNumber(widget.userId);

      // Send via API to get WhatsApp notification if phone is saved
      await apiService.sendNotification(
        userId: widget.userId,
        phoneNumber: phoneNumber,
        title: title,
        body: body,
        sendWhatsApp: true,
        sendLocal: true,
      );

      // Also show local notification immediately
      final notificationService = NotificationService();
      await notificationService.showImmediateNotification(
        title: title,
        body: body,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✅ Personalized notification sent!\nCheck WhatsApp if phone number is saved.',
            ),
            backgroundColor: _greenMood,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending personalized notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error sending notification'),
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

  Future<void> _sendPeriodReminder() async {
    try {
      final apiService = ApiService();

      // Calculate days until next period
      final daysUntil =
          int.tryParse(
            _getDaysUntilNextPeriod().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;

      // Call backend to generate cute period reminder using Gemini
      final response = await apiService.generatePeriodReminder(
        userId: widget.userId,
        daysUntil: daysUntil,
      );

      if (response != null && response['reminder'] != null) {
        final reminder = response['reminder'];
        final title = reminder['title'] ?? '🌸 Period Reminder';
        final body = reminder['body'] ?? 'Your period is coming soon!';

        // Show local notification
        final notificationService = NotificationService();
        await notificationService.showImmediateNotification(
          title: title,
          body: body,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '💕 Cute period reminder sent!\nCheck WhatsApp if phone number is saved.',
              ),
              backgroundColor: _primaryPink,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending period reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error sending period reminder'),
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
    if (_needsSetup && !_isLoading) {
      return CycleSetupScreen(
        userId: widget.userId,
        onComplete: () {
          setState(() {
            _needsSetup = false;
          });
          _loadPredictions();
        },
      );
    }

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
        title: Consumer<LocalizationProvider>(
          builder: (context, localization, _) {
            return Text(
              localization.getString('cycle'),
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
                          MenstruationReportScreen(userId: widget.userId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Consumer<LocalizationProvider>(
                    builder: (context, localization, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localization.getString('report'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
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
            onPressed: () async {
              // Show test menu
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Test Notifications'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: const Text('Immediate'),
                        subtitle: const Text('Show notification now'),
                        onTap: () async {
                          Navigator.pop(context);
                          final notificationService = NotificationService();
                          await notificationService.showImmediateNotification(
                            title: '🌸 Immediate Test',
                            body: 'This notification appeared instantly!',
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '✅ Immediate notification sent!',
                                ),
                                backgroundColor: _greenMood,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Scheduled (10s)'),
                        subtitle: const Text('Test background notification'),
                        onTap: () async {
                          Navigator.pop(context);
                          final notificationService = NotificationService();
                          await notificationService.scheduleNotification(
                            title: '🌸 Background Test',
                            body:
                                'This notification was scheduled! Close the app to test background.',
                            scheduledDate: DateTime.now().add(
                              const Duration(seconds: 10),
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '⏰ Notification scheduled in 10 seconds!\nClose the app to test background.',
                                ),
                                backgroundColor: _darkPink,
                                duration: const Duration(seconds: 5),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule_send),
                        title: const Text('Scheduled (30s)'),
                        subtitle: const Text('Longer background test'),
                        onTap: () async {
                          Navigator.pop(context);
                          final notificationService = NotificationService();
                          await notificationService.scheduleNotification(
                            title: '🌸 Period Reminder',
                            body:
                                'Your next period is expected in ${_getDaysUntilNextPeriod()}',
                            scheduledDate: DateTime.now().add(
                              const Duration(seconds: 30),
                            ),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '⏰ Notification scheduled in 30 seconds!\nMinimize the app to test.',
                                ),
                                backgroundColor: _darkPink,
                                duration: const Duration(seconds: 5),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: const Text('Personalized'),
                        subtitle: const Text('Based on your health data'),
                        onTap: () async {
                          Navigator.pop(context);
                          await _sendPersonalizedNotification();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite_border),
                        title: const Text('Period Reminder'),
                        subtitle: const Text('Cute & loving message'),
                        onTap: () async {
                          Navigator.pop(context);
                          await _sendPeriodReminder();
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accentPink))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Widget
                    StreakWidget(
                      userId: widget.userId,
                      category: 'menstruation',
                      onStreakUpdated: () {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    // Cycle Day Card
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
                            color: _primaryPink.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Consumer<LocalizationProvider>(
                        builder: (context, localization, _) {
                          return Column(
                            children: [
                              Text(
                                '${localization.getString('day')} $_currentCycleDay',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentPhase,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatChip(
                                    localization.getString('next_period'),
                                    _getDaysUntilNextPeriod(),
                                    Icons.calendar_today,
                                  ),
                                  _buildStatChip(
                                    localization.getString('cycle_length'),
                                    '${_predictions?['average_cycle_length'] ?? 28} days',
                                    Icons.repeat,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Consumer<LocalizationProvider>(
                      builder: (context, localization, _) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    localization.getString('cycle_calendar'),
                                    Icons.calendar_month,
                                    _greenMood,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CycleHistoryScreen(
                                                userId: widget.userId,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    localization.getString('ai_chat'),
                                    Icons.chat_bubble_outline,
                                    _purpleMood,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MenstruationAIChatScreen(
                                                userId: widget.userId,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    'Ranting AI',
                                    Icons.mic,
                                    const Color(0xFFD4C4E8),
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AgoraConversationalVoiceAgent(
                                                userId: widget.userId,
                                                agoraAppId:
                                                    'bb1ca613e3b94aa7af3eec189d172e99',
                                                mode: 'ranting',
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Container()),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // PCOS Tracking Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PCOSLogScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE8B4C4), Color(0xFFD4A5A5)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A5A5).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Color(0xFFD4A5A5),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PCOS Tracking',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Specialized tracking for PCOS',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Today's Log Section
                    const Text(
                      'Log Today',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Flow Level
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                                      color: _primaryPink.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: _darkPink,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Flow Level',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddCustomDialog(
                                  'Flow Level',
                                  _flowLevels,
                                ),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _darkPink,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _flowLevels.map((level) {
                              final isSelected = _flowLevel == level;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _flowLevel = level);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _primaryPink
                                        : _lightPink,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    level,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                                  color: _greenMood.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.mood,
                                  color: _greenMood,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'How are you feeling?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox.shrink(),
                              TextButton.icon(
                                onPressed: () =>
                                    _showAddCustomDialog('Mood', _moods),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _greenMood,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _moods.map((mood) {
                              final isSelected = _selectedMoods.contains(mood);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedMoods.remove(mood);
                                    } else {
                                      _selectedMoods.add(mood);
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
                                        ? _greenMood
                                        : _greenMood.withOpacity(0.2),
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
                                        mood,
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
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Symptoms
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                                      color: _purpleMood.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.healing,
                                      color: _purpleMood,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Symptoms',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _showAddCustomDialog('Symptom', _symptoms),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _purpleMood,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _symptoms.map((symptom) {
                              final isSelected = _selectedSymptoms.contains(
                                symptom,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedSymptoms.remove(symptom);
                                    } else {
                                      _selectedSymptoms.add(symptom);
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
                                        ? _purpleMood
                                        : _purpleMood.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    symptom,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Today\'s Log',
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
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
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
              color: Colors.black.withOpacity(0.6),
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
          color: color.withOpacity(0.2),
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

  void _showAddCustomDialog(String type, List<String> list) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom $type'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter custom $type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: _lightPink,
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
              if (value.isNotEmpty && !list.contains(value)) {
                setState(() => list.add(value));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "$value" to $type'),
                    backgroundColor: _primaryPink,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (list.contains(value)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$type already exists'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLog() async {
    final log = {
      'user_id': widget.userId,
      'date': DateTime.now().toIso8601String(),
      'cycle_day': _currentCycleDay,
      'flow_level': _flowLevel,
      'mood': _selectedMoods.join(', '),
      'symptoms': _selectedSymptoms,
      'notes': '',
    };

    final apiService = ApiService();
    final success = await apiService.addMenstruationLog(log);

    if (success) {
      await _loadPredictions();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Cycle log saved successfully! 📅'
                : 'Failed to save log. Please try again.',
          ),
          backgroundColor: success ? _greenMood : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
