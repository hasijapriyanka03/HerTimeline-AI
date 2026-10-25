import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/checklist_status.dart';
import '../services/api_service.dart';

class ChecklistScreen extends StatefulWidget {
  final String userId;
  final int currentWeek;

  const ChecklistScreen({
    super.key,
    required this.userId,
    required this.currentWeek,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final ApiService _apiService = ApiService();
  Map<String, List<ChecklistStatus>> _checklistByWeek = {};
  bool _isLoading = true;

  // Modern color palette
  static const Color _primaryYellow = Color(0xFFF7E8C8);
  static const Color _lightYellow = Color(0xFFFFFBE6);
  static const Color _accentYellow = Color(0xFFF7DC6F);
  static const Color _darkYellow = Color(0xFFD4A574);
  static const Color _backgroundColor = Color(0xFFFFFAF0);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _isLoading = true);

    try {
      // Load templates from JSON
      final String response = await rootBundle.loadString(
        'assets/data/checklist_templates.json',
      );
      final Map<String, dynamic> templates = json.decode(response);

      // Load user's saved progress from backend
      final savedProgress = await _apiService.getChecklist(
        widget.userId,
        widget.currentWeek,
      );

      // Create a map of completed tasks for quick lookup
      final Map<String, bool> completedTasks = {};
      for (var item in savedProgress) {
        final key = '${item.week}_${item.task}';
        completedTasks[key] = item.completed;
      }

      // Merge templates with saved progress
      final Map<String, List<ChecklistStatus>> checklist = {};

      templates.forEach((weekKey, tasks) {
        final week = int.parse(weekKey.split('_')[1]);
        checklist[weekKey] = (tasks as List).map((task) {
          final taskKey = '${week}_$task';
          final isCompleted = completedTasks[taskKey] ?? false;

          return ChecklistStatus(
            userId: widget.userId,
            week: week,
            task: task,
            completed: isCompleted,
          );
        }).toList();
      });

      if (mounted) {
        setState(() {
          _checklistByWeek = checklist;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading checklist: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTask(ChecklistStatus status) async {
    // Optimistically update UI
    setState(() {
      final weekKey = 'week_${status.week}';
      final index = _checklistByWeek[weekKey]!.indexWhere(
        (item) => item.task == status.task,
      );
      if (index != -1) {
        _checklistByWeek[weekKey]![index] = ChecklistStatus(
          userId: status.userId,
          week: status.week,
          task: status.task,
          completed: !status.completed,
        );
      }
    });

    // Save to backend
    final updated = ChecklistStatus(
      userId: status.userId,
      week: status.week,
      task: status.task,
      completed: !status.completed,
    );

    final success = await _apiService.updateChecklistTask(updated);

    if (!success && mounted) {
      // Revert on failure
      setState(() {
        final weekKey = 'week_${status.week}';
        final index = _checklistByWeek[weekKey]!.indexWhere(
          (item) => item.task == status.task,
        );
        if (index != -1) {
          _checklistByWeek[weekKey]![index] = status;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (success && mounted) {
      // Show success feedback for completed tasks
      if (updated.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task completed! ✓'),
            backgroundColor: _greenAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
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
    // Calculate progress
    int totalTasks = 0;
    int completedTasks = 0;
    _checklistByWeek.forEach((key, tasks) {
      totalTasks += tasks.length;
      completedTasks += tasks.where((t) => t.completed).length;
    });
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

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
          'Pregnancy Checklist',
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
          ? const Center(child: CircularProgressIndicator(color: _accentYellow))
          : RefreshIndicator(
              onRefresh: _loadChecklist,
              color: _accentYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_accentYellow, _lightYellow],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _accentYellow.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.checklist_rounded,
                              size: 48,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${(progress * 100).toInt()}% Complete',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$completedTasks of $totalTasks tasks done',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.5,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _greenAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Weekly Tasks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Week Cards
                      ..._checklistByWeek.entries.map((entry) {
                        final weekKey = entry.key;
                        final week = int.parse(weekKey.split('_')[1]);
                        final tasks = entry.value;
                        final isCurrentWeek = week == widget.currentWeek;
                        final weekCompleted = tasks
                            .where((t) => t.completed)
                            .length;
                        final weekTotal = tasks.length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: isCurrentWeek
                                ? Border.all(color: _accentYellow, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              childrenPadding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 16,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCurrentWeek
                                      ? _accentYellow.withValues(alpha: 0.3)
                                      : _primaryYellow.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: isCurrentWeek
                                      ? _darkYellow
                                      : _accentYellow,
                                  size: 20,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    'Week $week',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isCurrentWeek
                                          ? _darkYellow
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (isCurrentWeek) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentYellow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Current',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '$weekCompleted of $weekTotal completed',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              children: tasks.map((task) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: task.completed
                                        ? _greenAccent.withValues(alpha: 0.1)
                                        : _lightYellow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: CheckboxListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      task.task,
                                      style: TextStyle(
                                        fontSize: 15,
                                        decoration: task.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.completed
                                            ? Colors.black54
                                            : Colors.black87,
                                      ),
                                    ),
                                    value: task.completed,
                                    onChanged: (value) => _toggleTask(task),
                                    activeColor: _greenAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
