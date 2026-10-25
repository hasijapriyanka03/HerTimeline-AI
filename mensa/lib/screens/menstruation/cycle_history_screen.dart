import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart';

class CycleHistoryScreen extends StatefulWidget {
  final String userId;

  const CycleHistoryScreen({super.key, required this.userId});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, Map<String, dynamic>> _logsMap = {};
  bool _isLoading = true;

  // Soft, calming colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
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
      final apiService = ApiService();

      final logs = await apiService.getMenstruationLogs(widget.userId);

      final logsMap = <DateTime, Map<String, dynamic>>{};
      for (var log in logs) {
        final date = DateTime.parse(log['date']);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        logsMap[normalizedDate] = {
          'cycle_day': log['cycle_day'] ?? 0,
          'flow_level': log['flow_level'] ?? 'None',
          'mood': log['mood'] ?? 'Calm',
          'symptoms': (log['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
          'notes': log['notes'] ?? '',
        };
      }

      setState(() {
        _logsMap = logsMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_logsMap.containsKey(normalizedDay)) {
      return [_logsMap[normalizedDay]!];
    }
    return [];
  }

  bool _isPeriodDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final log = _logsMap[normalizedDay];
    if (log == null) return false;
    final flowLevel = log['flow_level'] as String;
    return flowLevel != 'None';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calendar',
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
          ? const Center(child: CircularProgressIndicator(color: _accentPink))
          : Column(
              children: [
                // Month Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        'Menstruation',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 28),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Calendar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _lightPink,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerVisible: false,
                    daysOfWeekHeight: 40,
                    rowHeight: 48,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      todayDecoration: BoxDecoration(
                        color: _darkPink,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: _darkPink,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (_isPeriodDay(day)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _primaryPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final isPeriod = _isPeriodDay(day);
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isPeriod ? _darkPink : _darkPink,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isPeriod
                                ? const Icon(
                                    Icons.water_drop,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Today's Mood Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _selectedDay == null
                        ? const Center(child: Text('Select a date'))
                        : _buildDayDetails(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDayDetails() {
    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final log = _logsMap[normalizedDay];

    if (log == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s mood',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No data for this day',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      );
    }

    final mood = log['mood'] as String;
    final symptoms = log['symptoms'] as List<String>;
    final flowLevel = log['flow_level'] as String;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s mood',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Mood Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodIcon(
                'Happy',
                Icons.sentiment_satisfied,
                const Color(0xFFB8D4C8),
                mood == 'Happy',
              ),
              _buildMoodIcon(
                'Tired',
                Icons.sentiment_neutral,
                const Color(0xFFE8C4C4),
                mood == 'Tired',
              ),
              _buildMoodIcon(
                'Irritable',
                Icons.sentiment_dissatisfied,
                const Color(0xFFE8C4D4),
                mood == 'Irritable',
              ),
              _buildMoodIcon(
                'Cramps',
                Icons.bolt,
                const Color(0xFFD4C4E8),
                symptoms.contains('Cramps'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Flow Level
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lightPink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Flow Level',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flowLevel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Symptoms
          if (symptoms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Symptoms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptoms.map((symptom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          symptom,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodIcon(
    String label,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.white : color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black87 : Colors.black54,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
