import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final double dailyCalorieGoal;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activityLevel;
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.dailyCalorieGoal,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dailyCalorieGoal': dailyCalorieGoal,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      dailyCalorieGoal: (data['dailyCalorieGoal'] ?? 2000).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      activityLevel: data['activityLevel'] ?? 'moderate',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? email,
    double? dailyCalorieGoal,
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? activityLevel,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt,
    );
  }
}