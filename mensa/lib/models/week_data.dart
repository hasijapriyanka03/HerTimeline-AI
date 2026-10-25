class WeekData {
  final int week;
  final String babyGrowth;
  final String bodyChanges;
  final String tips;

  WeekData({
    required this.week,
    required this.babyGrowth,
    required this.bodyChanges,
    required this.tips,
  });

  factory WeekData.fromJson(Map<String, dynamic> json) {
    return WeekData(
      week: json['week'],
      babyGrowth: json['baby_growth'],
      bodyChanges: json['body_changes'],
      tips: json['tips'],
    );
  }
}
