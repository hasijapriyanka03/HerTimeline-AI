import 'package:flutter/material.dart';
import 'cycle_log_screen.dart';
import 'pcos_log_screen.dart';
import 'cycle_calendar_screen.dart';
import 'cycle_insights_screen.dart';

class MenstruationDashboard extends StatefulWidget {
  final String userId;
  final bool hasPCOS;

  const MenstruationDashboard({
    super.key,
    required this.userId,
    this.hasPCOS = false,
  });

  @override
  State<MenstruationDashboard> createState() => _MenstruationDashboardState();
}

class _MenstruationDashboardState extends State<MenstruationDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CycleCalendarScreen(userId: widget.userId),
      // Use PCOS log screen if user has PCOS, otherwise regular log
      widget.hasPCOS
          ? PCOSLogScreen(userId: widget.userId)
          : CycleLogScreen(userId: widget.userId),
      CycleInsightsScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFFFB6C1),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.hasPCOS ? Icons.favorite : Icons.add_circle),
            label: widget.hasPCOS ? 'PCOS Log' : 'Log',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
