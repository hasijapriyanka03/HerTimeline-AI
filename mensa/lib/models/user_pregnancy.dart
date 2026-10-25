class UserPregnancy {
  final String userId;
  final DateTime lmpDate;
  final DateTime dueDate;
  final List<String> allergies;
  final List<String> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPregnancy({
    required this.userId,
    required this.lmpDate,
    required this.dueDate,
    required this.allergies,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  int get currentWeek {
    final now = DateTime.now();
    final difference = now.difference(lmpDate).inDays;
    return (difference / 7).floor();
  }

  int get trimester {
    final week = currentWeek;
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  factory UserPregnancy.fromJson(Map<String, dynamic> json) {
    return UserPregnancy(
      userId: json['user_id'],
      lmpDate: DateTime.parse(json['lmp_date']),
      dueDate: DateTime.parse(json['due_date']),
      allergies: List<String>.from(json['allergies'] ?? []),
      preferences: List<String>.from(json['preferences'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'lmp_date': lmpDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'allergies': allergies,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
