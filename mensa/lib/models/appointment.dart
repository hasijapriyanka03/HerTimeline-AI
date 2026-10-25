class Appointment {
  final String id;
  final String userId;
  final String title;
  final String type; // checkup, ultrasound, test, consultation
  final DateTime dateTime;
  final String? doctorName;
  final String? location;
  final String? notes;
  final bool reminderSet;
  final int reminderMinutesBefore; // 60 = 1 hour, 1440 = 1 day
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.dateTime,
    this.doctorName,
    this.location,
    this.notes,
    this.reminderSet = true,
    this.reminderMinutesBefore = 1440, // Default: 1 day before
    this.completed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      'date_time': dateTime.toIso8601String(),
      'doctor_name': doctorName,
      'location': location,
      'notes': notes,
      'reminder_set': reminderSet,
      'reminder_minutes_before': reminderMinutesBefore,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'checkup',
      dateTime: DateTime.parse(json['date_time']),
      doctorName: json['doctor_name'],
      location: json['location'],
      notes: json['notes'],
      reminderSet: json['reminder_set'] ?? true,
      reminderMinutesBefore: json['reminder_minutes_before'] ?? 1440,
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Appointment copyWith({
    String? id,
    String? userId,
    String? title,
    String? type,
    DateTime? dateTime,
    String? doctorName,
    String? location,
    String? notes,
    bool? reminderSet,
    int? reminderMinutesBefore,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      doctorName: doctorName ?? this.doctorName,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      reminderSet: reminderSet ?? this.reminderSet,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
