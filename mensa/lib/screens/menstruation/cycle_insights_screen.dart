import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CycleInsightsScreen extends StatefulWidget {
  final String userId;

  const CycleInsightsScreen({super.key, required this.userId});

  @override
  State<CycleInsightsScreen> createState() => _CycleInsightsScreenState();
}

class _CycleInsightsScreenState extends State<CycleInsightsScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _insights = [];
  List<dynamic> _commonSymptoms = [];
  int _totalLogs = 0;
  int _cycleRegularity = 0;
  int _avgCycleLength = 28;

  // Soft, calming colors
  static const Color _primaryPink = Color(0xFFE8C4C4);
  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _purpleAccent = Color(0xFFD4C4E8);
  static const Color _blueAccent = Color(0xFFA8D8EA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsights();
    });
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _apiService.getMenstruationStats(widget.userId);
      final predictions = await _apiService.getMenstruationPredictions(
        widget.userId,
      );

      if (stats != null && mounted) {
        setState(() {
          _insights = stats['insights'] ?? [];
          _commonSymptoms = stats['common_symptoms'] ?? [];
          _totalLogs = stats['total_logs'] ?? 0;
          _cycleRegularity = predictions?['cycle_regularity'] ?? 0;
          _avgCycleLength = predictions?['average_cycle_length'] ?? 28;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading insights: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            'Cycle Insights',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator(color: _darkPink)),
      );
    }

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
          'Cycle Insights',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadInsights,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Stats Card
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
                  const Text(
                    'Your Cycle Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total Logs',
                        '$_totalLogs',
                        Icons.event_note,
                      ),
                      _buildStatItem(
                        'Avg Cycle',
                        '$_avgCycleLength days',
                        Icons.repeat,
                      ),
                      _buildStatItem(
                        'Regularity',
                        '$_cycleRegularity%',
                        _cycleRegularity >= 90
                            ? Icons.check_circle
                            : _cycleRegularity >= 70
                            ? Icons.info
                            : Icons.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // AI Insights Section
            if (_insights.isNotEmpty) ...[
              const Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ..._insights.map((insight) => _buildInsightCard(insight)),
              const SizedBox(height: 24),
            ],

            // Common Symptoms Section
            if (_commonSymptoms.isNotEmpty) ...[
              const Text(
                'Common Symptoms',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ..._commonSymptoms.map(
                (symptom) => _buildSymptomCard(
                  symptom['symptom'] ?? 'Unknown',
                  symptom['count'] ?? 0,
                  symptom['percentage'] ?? 0,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Health Tips Section
            const Text(
              'Health Tips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
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
                children: [
                  _buildTipItem(
                    '💧 Stay hydrated during your period',
                    _greenAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    '🏃‍♀️ Light exercise can help with cramps',
                    _greenAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    '🥗 Iron-rich foods prevent fatigue',
                    _greenAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    '📝 Track symptoms daily for better insights',
                    _greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cycle Health Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cycleRegularity >= 90
                    ? _greenAccent.withValues(alpha: 0.2)
                    : _cycleRegularity >= 70
                    ? Colors.orange.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _cycleRegularity >= 90
                      ? _greenAccent
                      : _cycleRegularity >= 70
                      ? Colors.orange
                      : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cycleRegularity >= 90
                          ? _greenAccent
                          : _cycleRegularity >= 70
                          ? Colors.orange
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _cycleRegularity >= 90
                          ? Icons.check_circle
                          : _cycleRegularity >= 70
                          ? Icons.info
                          : Icons.warning,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cycleRegularity >= 90
                              ? 'Cycle is Regular'
                              : _cycleRegularity >= 70
                              ? 'Cycle is Moderate'
                              : 'Cycle is Irregular',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cycleRegularity >= 90
                              ? 'Your cycle is healthy and regular. Keep tracking!'
                              : _cycleRegularity >= 70
                              ? 'Your cycle shows some variation. Continue tracking.'
                              : 'Consider consulting a healthcare provider if this persists.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Empty State
            if (_totalLogs == 0) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _blueAccent.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights,
                        size: 48,
                        color: _blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Start Tracking Your Cycle',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log your cycle daily to get personalized insights, predictions, and health recommendations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: _darkPink, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    Color cardColor;
    Color iconColor;
    IconData icon;

    switch (insight['type']) {
      case 'positive':
        cardColor = _greenAccent.withValues(alpha: 0.2);
        iconColor = _greenAccent;
        icon = Icons.check_circle;
        break;
      case 'warning':
        cardColor = Colors.orange.shade100;
        iconColor = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case 'recommendation':
        cardColor = _blueAccent.withValues(alpha: 0.2);
        iconColor = _blueAccent;
        icon = Icons.lightbulb;
        break;
      default:
        cardColor = _purpleAccent.withValues(alpha: 0.2);
        iconColor = _purpleAccent;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] ?? 'Insight',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['message'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCard(String symptom, int count, int percentage) {
    Color severityColor;
    String severity;

    if (percentage >= 50) {
      severityColor = Colors.red;
      severity = 'High';
    } else if (percentage >= 25) {
      severityColor = Colors.orange;
      severity = 'Medium';
    } else {
      severityColor = _greenAccent;
      severity = 'Low';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.healing, color: severityColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% of logged days ($count times)',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              severity,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
