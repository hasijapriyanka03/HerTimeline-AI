import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class PregnancyHistoryScreen extends StatefulWidget {
  final String userId;

  const PregnancyHistoryScreen({super.key, required this.userId});

  @override
  State<PregnancyHistoryScreen> createState() => _PregnancyHistoryScreenState();
}

class _PregnancyHistoryScreenState extends State<PregnancyHistoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<DailyLog> _dailyLogs = [];
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  // Modern color palette
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _blueAccent = Color(0xFF64B5F6);
  static const Color _purpleAccent = Color(0xFFD4C4E8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      // Load daily logs
      final logs = await _apiService.getDailyLogs(widget.userId);

      // Load appointments
      final appointmentsData = await _apiService.getAppointments(widget.userId);
      final appointments = appointmentsData
          .map((data) => Appointment.fromJson(data))
          .toList();

      if (mounted) {
        setState(() {
          _dailyLogs = logs;
          _appointments = appointments;
          _appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text(
          'Pregnancy History',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _darkPink,
          unselectedLabelColor: Colors.black54,
          indicatorColor: _darkPink,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Daily Logs'),
            Tab(text: 'Appointments'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accentPink))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: _accentPink,
              child: TabBarView(
                controller: _tabController,
                children: [_buildDailyLogsTab(), _buildAppointmentsTab()],
              ),
            ),
    );
  }

  Widget _buildDailyLogsTab() {
    if (_dailyLogs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.edit_note,
        title: 'No Daily Logs Yet',
        subtitle: 'Start logging your daily wellness to see your history here',
      );
    }

    // Group logs by month
    final groupedLogs = <String, List<DailyLog>>{};
    for (var log in _dailyLogs) {
      final monthKey = DateFormat('MMMM yyyy').format(log.date);
      groupedLogs.putIfAbsent(monthKey, () => []).add(log);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groupedLogs.length,
      itemBuilder: (context, index) {
        final monthKey = groupedLogs.keys.elementAt(index);
        final logs = groupedLogs[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 16),
              child: Text(
                monthKey,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Logs for this month
            ...logs.map((log) => _buildDailyLogCard(log)),
          ],
        );
      },
    );
  }

  Widget _buildDailyLogCard(DailyLog log) {
    return Container(
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
            // Date and Mood
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _purpleAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: _purpleAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEE, MMM d').format(log.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getMoodColor(log.mood).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMoodIcon(log.mood),
                        size: 16,
                        color: _getMoodColor(log.mood),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.mood,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getMoodColor(log.mood),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats Row
            Row(
              children: [
                _buildStatItem(
                  Icons.water_drop,
                  '${log.water.toInt()} glasses',
                  _blueAccent,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.monitor_weight,
                  '${log.weight.toStringAsFixed(1)} lbs',
                  _purpleAccent,
                ),
              ],
            ),
            // Symptoms
            if (log.symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: log.symptoms.map((symptom) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _lightPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symptom,
                      style: TextStyle(fontSize: 12, color: _darkPink),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_available,
        title: 'No Appointments Yet',
        subtitle: 'Add appointments to track your healthcare visits',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final isPast = appointment.isPast || appointment.completed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: appointment.completed
                ? Border.all(color: _greenAccent, width: 2)
                : null,
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
                // Date Badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      appointment.type,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appointment.dateTime.day.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(appointment.type),
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(appointment.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(appointment.type),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPast ? Colors.black54 : Colors.black87,
                                decoration: appointment.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (appointment.completed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _greenAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      if (appointment.doctorName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.black.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'energetic':
        return _greenAccent;
      case 'calm':
        return _blueAccent;
      case 'anxious':
      case 'stressed':
        return const Color(0xFFFF9800);
      case 'tired':
      case 'sad':
        return _purpleAccent;
      default:
        return _accentPink;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
        return Icons.sentiment_very_satisfied;
      case 'calm':
      case 'energetic':
        return Icons.sentiment_satisfied;
      case 'anxious':
      case 'stressed':
        return Icons.sentiment_dissatisfied;
      case 'tired':
      case 'sad':
        return Icons.sentiment_neutral;
      default:
        return Icons.mood;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return _greenAccent;
      case 'ultrasound':
        return _blueAccent;
      case 'test':
        return _purpleAccent;
      case 'consultation':
        return const Color(0xFFFFB74D);
      default:
        return _accentPink;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
