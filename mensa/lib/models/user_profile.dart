class UserProfile {
  final String userId;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String bloodType;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? emergencyEmail;
  final String trackerType; // 'pregnancy', 'menstruation', 'menopause'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    this.bloodType = 'Unknown',
    this.medicalConditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.emergencyContact,
    this.emergencyPhone,
    this.emergencyEmail,
    this.trackerType = 'menstruation',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'blood_type': bloodType,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'emergency_email': emergencyEmail,
      'tracker_type': trackerType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      bloodType: json['blood_type'] ?? 'Unknown',
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      emergencyEmail: json['emergency_email'],
      trackerType: json['tracker_type'] ?? 'menstruation',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
