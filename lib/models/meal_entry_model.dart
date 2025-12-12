import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntryModel {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime dateTime;

  MealEntryModel({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.mealType,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodId': foodId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'mealType': mealType,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  factory MealEntryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MealEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      foodId: data['foodId'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      mealType: data['mealType'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
    );
  }
}

class DailySummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealsCount;

  DailySummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealsCount,
  });
}