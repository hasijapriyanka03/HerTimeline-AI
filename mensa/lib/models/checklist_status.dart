class ChecklistStatus {
  final String userId;
  final int week;
  final String task;
  final bool completed;

  ChecklistStatus({
    required this.userId,
    required this.week,
    required this.task,
    required this.completed,
  });

  factory ChecklistStatus.fromJson(Map<String, dynamic> json) {
    return ChecklistStatus(
      userId: json['user_id'],
      week: json['week'],
      task: json['task'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'week': week,
      'task': task,
      'completed': completed,
    };
  }
}
