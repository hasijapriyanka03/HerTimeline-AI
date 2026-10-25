class Streak {
  final String streakId;
  final String userId;
  final String category; // 'menstruation', 'pregnancy', 'menopause'
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckInDate;
  final List<DateTime> checkInDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  Streak({
    required this.streakId,
    required this.userId,
    required this.category,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    required this.checkInDates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      streakId: json['streak_id'] ?? '',
      userId: json['user_id'] ?? '',
      category: json['category'] ?? 'menstruation',
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastCheckInDate: json['last_check_in_date'] != null
          ? DateTime.parse(json['last_check_in_date'])
          : null,
      checkInDates:
          (json['check_in_dates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date.toString()))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak_id': streakId,
      'user_id': userId,
      'category': category,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_check_in_date': lastCheckInDate?.toIso8601String(),
      'check_in_dates': checkInDates.map((d) => d.toIso8601String()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isStreakActive {
    if (lastCheckInDate == null) return false;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final lastCheckInDay = DateTime(
      lastCheckInDate!.year,
      lastCheckInDate!.month,
      lastCheckInDate!.day,
    );
    final todayDay = DateTime(today.year, today.month, today.day);
    final yesterdayDay = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );

    return lastCheckInDay == todayDay || lastCheckInDay == yesterdayDay;
  }

  bool get canCheckInToday {
    if (lastCheckInDate == null) return true;
    final today = DateTime.now();
    final lastCheckInDay = DateTime(
      lastCheckInDate!.year,
      lastCheckInDate!.month,
      lastCheckInDate!.day,
    );
    final todayDay = DateTime(today.year, today.month, today.day);

    return lastCheckInDay != todayDay;
  }
}

class StreakSummary {
  final int totalActiveStreaks;
  final Map<String, StreakData> streaksByCategory;
  final int totalPointsEarned;

  StreakSummary({
    required this.totalActiveStreaks,
    required this.streaksByCategory,
    required this.totalPointsEarned,
  });

  factory StreakSummary.fromJson(Map<String, dynamic> json) {
    final streaksByCategory = <String, StreakData>{};
    final categoryData = json['streaks_by_category'] as Map<String, dynamic>?;

    if (categoryData != null) {
      categoryData.forEach((key, value) {
        streaksByCategory[key] = StreakData.fromJson(value);
      });
    }

    return StreakSummary(
      totalActiveStreaks: json['total_active_streaks'] ?? 0,
      streaksByCategory: streaksByCategory,
      totalPointsEarned: json['total_points_earned'] ?? 0,
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckIn;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckIn,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'])
          : null,
    );
  }
}
