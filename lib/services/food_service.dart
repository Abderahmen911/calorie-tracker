import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';
import '../models/meal_entry_model.dart';

class FoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all foods
  Stream<List<FoodModel>> getAllFoods() {
    return _db
        .collection('foods')
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FoodModel.fromFirestore(doc)).toList());
  }

  // Search foods
  Stream<List<FoodModel>> searchFoods(String query) {
    return _db
        .collection('foods')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final foods = snapshot.docs
          .map((doc) => FoodModel.fromFirestore(doc))
          .toList();
      
      if (query.isEmpty) return foods;
      
      return foods.where((food) {
        return food.name.toLowerCase().contains(query.toLowerCase()) ||
            food.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Get foods by category
  Stream<List<FoodModel>> getFoodsByCategory(String category) {
    return _db
        .collection('foods')
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FoodModel.fromFirestore(doc)).toList());
  }

  // Add custom food
  Future<void> addFood(FoodModel food) async {
    await _db.collection('foods').add(food.toMap());
  }

  // Add meal entry
  Future<void> addMealEntry(MealEntryModel entry) async {
    await _db.collection('meal_entries').add(entry.toMap());
  }

  // Get meal entries for today
  Stream<List<MealEntryModel>> getTodayMeals(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection('meal_entries')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealEntryModel.fromFirestore(doc))
            .toList());
  }

  // Get meal entries for a specific date
  Stream<List<MealEntryModel>> getMealsByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection('meal_entries')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealEntryModel.fromFirestore(doc))
            .toList());
  }

  // Delete meal entry
  Future<void> deleteMealEntry(String entryId) async {
    await _db.collection('meal_entries').doc(entryId).delete();
  }

  // Calculate daily summary
  DailySummary calculateDailySummary(List<MealEntryModel> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var meal in meals) {
      totalCalories += meal.calories * meal.quantity;
      totalProtein += meal.protein * meal.quantity;
      totalCarbs += meal.carbs * meal.quantity;
      totalFat += meal.fat * meal.quantity;
    }

    return DailySummary(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      mealsCount: meals.length,
    );
  }

  // Get weekly summary
  Future<Map<DateTime, double>> getWeeklySummary(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final snapshot = await _db
        .collection('meal_entries')
        .where('userId', isEqualTo: userId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

    final meals = snapshot.docs
        .map((doc) => MealEntryModel.fromFirestore(doc))
        .toList();

    Map<DateTime, double> dailyCalories = {};

    for (var meal in meals) {
      final date = DateTime(
        meal.dateTime.year,
        meal.dateTime.month,
        meal.dateTime.day,
      );
      dailyCalories[date] = (dailyCalories[date] ?? 0) + (meal.calories * meal.quantity);
    }

    return dailyCalories;
  }
}