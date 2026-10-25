class DailyLog {
  final String? logId;
  final String userId;
  final DateTime date;
  final String mood;
  final List<String> symptoms;
  final double water;
  final double weight;

  DailyLog({
    this.logId,
    required this.userId,
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.water,
    required this.weight,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      logId: json['log_id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      water: (json['water'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logId != null) 'log_id': logId,
      'user_id': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'symptoms': symptoms,
      'water': water,
      'weight': weight,
    };
  }
}
