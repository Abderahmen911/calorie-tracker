import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String category;
  final double servingSize;
  final String servingUnit;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
    required this.servingSize,
    required this.servingUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'category': category,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
    };
  }

  factory FoodModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FoodModel(
      id: doc.id,
      name: data['name'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      servingSize: (data['servingSize'] ?? 0).toDouble(),
      servingUnit: data['servingUnit'] ?? 'g',
    );
  }
}