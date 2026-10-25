import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class MenopauseHistoryScreen extends StatefulWidget {
  final String userId;

  const MenopauseHistoryScreen({super.key, required this.userId});

  @override
  State<MenopauseHistoryScreen> createState() => _MenopauseHistoryScreenState();
}

class _MenopauseHistoryScreenState extends State<MenopauseHistoryScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _accentPurple = Color(0xFFD4C4E8);
  static const Color _darkPurple = Color(0xFF9B7FC8);
  static const Color _backgroundColor = Color(0xFFFAF5FF);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final logs = await apiService.getMenopauseLogs(widget.userId);

      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _isLoading = false);
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
          'Health History',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _darkPurple))
          : _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: _accentPurple),
                  const SizedBox(height: 16),
                  const Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start logging your symptoms to see history',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final date = DateTime.parse(log['date']);
                final symptoms = log['symptoms'] as List? ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                          Text(
                            DateFormat('EEEE, MMM d').format(date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _lightPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              log['mood'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12,
                                color: _darkPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.local_fire_department,
                            'Hot Flashes',
                            '${log['hot_flashes'] ?? 0}',
                            Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.bedtime,
                            'Sleep',
                            '${log['sleep_quality'] ?? 0}/10',
                            Colors.blue,
                          ),
                        ],
                      ),
                      if (symptoms.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Symptoms:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: symptoms.map((symptom) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _accentPurple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                symptom.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (log['notes'] != null &&
                          log['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          log['notes'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
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
    );
  }
}
