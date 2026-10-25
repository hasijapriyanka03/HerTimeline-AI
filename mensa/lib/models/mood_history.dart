class MoodHistory {
  final String userId;
  final DateTime date;
  final String mood;
  final double sentimentScore;
  final String suggestionGiven;
  final bool suggestionUsed;

  MoodHistory({
    required this.userId,
    required this.date,
    required this.mood,
    required this.sentimentScore,
    required this.suggestionGiven,
    required this.suggestionUsed,
  });

  factory MoodHistory.fromJson(Map<String, dynamic> json) {
    return MoodHistory(
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      sentimentScore: (json['sentiment_score'] ?? 0).toDouble(),
      suggestionGiven: json['suggestion_given'] ?? '',
      suggestionUsed: json['suggestion_used'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'sentiment_score': sentimentScore,
      'suggestion_given': suggestionGiven,
      'suggestion_used': suggestionUsed,
    };
  }
}
