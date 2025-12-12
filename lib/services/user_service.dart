import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get user profile
  Future<UserProfileModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfileModel.fromFirestore(doc);
    }
    return null;
  }

  // Stream user profile
  Stream<UserProfileModel?> streamUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfileModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // Update daily calorie goal
  Future<void> updateCalorieGoal(String userId, double goal) async {
    await _db.collection('users').doc(userId).update({
      'dailyCalorieGoal': goal,
    });
  }

  // Calculate recommended calories (BMR + activity level)
  double calculateRecommendedCalories({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    double bmr;
    
    // Mifflin-St Jeor Equation
    if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'homme') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
    double multiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
      case 'sédentaire':
        multiplier = 1.2;
        break;
      case 'light':
      case 'léger':
        multiplier = 1.375;
        break;
      case 'moderate':
      case 'modéré':
        multiplier = 1.55;
        break;
      case 'active':
      case 'actif':
        multiplier = 1.725;
        break;
      case 'very active':
      case 'très actif':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.55;
    }

    return bmr * multiplier;
  }
}