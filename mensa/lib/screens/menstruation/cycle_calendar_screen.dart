import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart';

class CycleCalendarScreen extends StatefulWidget {
  final String userId;

  const CycleCalendarScreen({super.key, required this.userId});

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  final ApiService _apiService = ApiService();

  // Calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Data
  bool _isLoading = true;

  // Cycle info
  int _currentCycleDay = 1;
  String _currentPhase = 'Menstrual Phase';
  String _daysUntilNextPeriod = '--';
  int _avgCycleLength = 28;
  String _lastPeriodDate = '--';
  int _cycleRegularity = 0;

  // Colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final predictions = await _apiService.getMenstruationPredictions(
        widget.userId,
      );
      // Load logs for future use (symptom markers on calendar)
      await _apiService.getMenstruationLogs(widget.userId);

      if (predictions != null && mounted) {
        final lastPeriod = predictions['last_period_start'] != null
            ? DateTime.parse(predictions['last_period_start'])
            : null;
        final today = DateTime.now();

        int cycleDay = 1;
        if (lastPeriod != null) {
          cycleDay = today.difference(lastPeriod).inDays + 1;
        }

        final nextPeriod = predictions['predicted_next_period'] != null
            ? DateTime.parse(predictions['predicted_next_period'])
            : null;

        int daysUntil = 0;
        String daysText = '--';
        if (nextPeriod != null) {
          daysUntil = nextPeriod.difference(today).inDays;
          if (daysUntil < 0) {
            daysText = 'Overdue';
          } else if (daysUntil == 0) {
            daysText = 'Today';
          } else if (daysUntil == 1) {
            daysText = 'Tomorrow';
          } else {
            daysText = '$daysUntil days';
          }
        }

        setState(() {
          _currentCycleDay = cycleDay;
          _currentPhase = _getCyclePhase(cycleDay);
          _daysUntilNextPeriod = daysText;
          _avgCycleLength = predictions['average_cycle_length'] ?? 28;
          _cycleRegularity = predictions['cycle_regularity'] ?? 0;
          _lastPeriodDate = lastPeriod != null
              ? '${lastPeriod.difference(today).inDays.abs()} days ago'
              : '--';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getCyclePhase(int day) {
    if (day <= 5) return 'Menstrual Phase';
    if (day <= 13) return 'Follicular Phase';
    if (day <= 16) return 'Ovulation Phase';
    return 'Luteal Phase';
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstrual Phase':
        return Colors.red.shade300;
      case 'Follicular Phase':
        return Colors.green.shade300;
      case 'Ovulation Phase':
        return Colors.purple.shade300;
      case 'Luteal Phase':
        return Colors.orange.shade300;
      default:
        return _primaryPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Cycle Calendar'),
          backgroundColor: _backgroundColor,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: const Center(child: CircularProgressIndicator(color: _darkPink)),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cycle Calendar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Cycle Info Card
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
                    'Day $_currentCycleDay of Cycle',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(
                        _currentPhase,
                      ).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentPhase,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(
                        'Next Period',
                        _daysUntilNextPeriod,
                        Icons.calendar_today,
                      ),
                      _buildInfoChip(
                        'Avg Cycle',
                        '$_avgCycleLength days',
                        Icons.repeat,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Calendar
            Container(
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
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: _primaryPink,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: _darkPink,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Cycle Statistics
            const Text(
              'Cycle Statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              'Average Cycle Length',
              '$_avgCycleLength days',
              Icons.calendar_month,
              _primaryPink,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Last Period',
              _lastPeriodDate,
              Icons.event,
              const Color(0xFFD4C4E8),
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Cycle Regularity',
              '$_cycleRegularity% ${_cycleRegularity >= 90
                  ? "Regular"
                  : _cycleRegularity >= 70
                  ? "Moderate"
                  : "Irregular"}',
              _cycleRegularity >= 90
                  ? Icons.check_circle
                  : _cycleRegularity >= 70
                  ? Icons.info
                  : Icons.warning,
              _cycleRegularity >= 90
                  ? const Color(0xFFB8D4C8)
                  : _cycleRegularity >= 70
                  ? Colors.orange.shade300
                  : Colors.red.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
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
              fontSize: 18,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
