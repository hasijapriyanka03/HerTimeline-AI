class MenstruationLog {
  final String? logId;
  final String userId;
  final DateTime date;
  final int cycleDay;
  final String flowLevel;
  final String mood;
  final List<String> symptoms;
  final String? notes;

  MenstruationLog({
    this.logId,
    required this.userId,
    required this.date,
    required this.cycleDay,
    required this.flowLevel,
    required this.mood,
    required this.symptoms,
    this.notes,
  });

  factory MenstruationLog.fromJson(Map<String, dynamic> json) {
    return MenstruationLog(
      logId: json['log_id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      cycleDay: json['cycle_day'],
      flowLevel: json['flow_level'],
      mood: json['mood'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (logId != null) 'log_id': logId,
      'user_id': userId,
      'date': date.toIso8601String(),
      'cycle_day': cycleDay,
      'flow_level': flowLevel,
      'mood': mood,
      'symptoms': symptoms,
      if (notes != null) 'notes': notes,
    };
  }
}

class MenstruationCycleData {
  final String userId;
  final int averageCycleLength;
  final DateTime lastPeriodStart;
  final DateTime predictedNextPeriod;
  final double cycleRegularity; // percentage
  final DateTime createdAt;
  final DateTime updatedAt;

  MenstruationCycleData({
    required this.userId,
    required this.averageCycleLength,
    required this.lastPeriodStart,
    required this.predictedNextPeriod,
    required this.cycleRegularity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenstruationCycleData.fromJson(Map<String, dynamic> json) {
    return MenstruationCycleData(
      userId: json['user_id'],
      averageCycleLength: json['average_cycle_length'],
      lastPeriodStart: DateTime.parse(json['last_period_start']),
      predictedNextPeriod: DateTime.parse(json['predicted_next_period']),
      cycleRegularity: (json['cycle_regularity'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'average_cycle_length': averageCycleLength,
      'last_period_start': lastPeriodStart.toIso8601String(),
      'predicted_next_period': predictedNextPeriod.toIso8601String(),
      'cycle_regularity': cycleRegularity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
