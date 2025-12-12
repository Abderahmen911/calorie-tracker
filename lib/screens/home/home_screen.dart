import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/food_service.dart';
import '../../services/user_service.dart';
import '../../models/meal_entry_model.dart';
import '../../models/user_profile_model.dart';
import '../add_meal/add_meal_screen.dart';
import '../profile/profile_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FoodService _foodService = FoodService();
  final UserService _userService = UserService();
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser!.uid;

    final screens = [
      _buildHomeContent(userId),
      HistoryScreen(userId: userId),
      ProfileScreen(userId: userId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Aujourd\'hui'
              : _selectedIndex == 1
                  ? 'Historique'
                  : 'Profil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ]
            : null,
      ),
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealScreen(
                      userId: userId,
                      selectedDate: _selectedDate,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Aujourd\'hui',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(String userId) {
    return StreamBuilder<UserProfileModel?>(
      stream: _userService.streamUserProfile(userId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userProfile = userSnapshot.data!;

        return StreamBuilder<List<MealEntryModel>>(
          stream: _foodService.getMealsByDate(userId, _selectedDate),
          builder: (context, mealsSnapshot) {
            if (mealsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final meals = mealsSnapshot.data ?? [];
            final summary = _foodService.calculateDailySummary(meals);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalorieCard(summary, userProfile.dailyCalorieGoal),
                  const SizedBox(height: 24),
                  _buildMacrosCard(summary),
                  const SizedBox(height: 24),
                  _buildMealsList(meals),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalorieCard(DailySummary summary, double goal) {
    final percentage = (summary.totalCalories / goal * 100).clamp(0, 100);
    final remaining = (goal - summary.totalCalories).round();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy', 'fr_FR').format(_selectedDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${summary.totalCalories.round()}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'sur ${goal.round()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: remaining >= 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    remaining >= 0 ? Icons.check_circle : Icons.warning,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    remaining >= 0
                        ? 'Il reste $remaining calories'
                        : 'Dépassé de ${remaining.abs()} calories',
                    style: TextStyle(
                      color: remaining >= 0 ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard(DailySummary summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutriments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(
                  'Protéines',
                  summary.totalProtein,
                  Colors.blue,
                  Icons.fitness_center,
                ),
                _buildMacroItem(
                  'Glucides',
                  summary.totalCarbs,
                  Colors.orange,
                  Icons.bakery_dining,
                ),
                _buildMacroItem(
                  'Lipides',
                  summary.totalFat,
                  Colors.purple,
                  Icons.water_drop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.round()}g',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList(List<MealEntryModel> meals) {
    if (meals.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.restaurant, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun repas enregistré',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final mealsByType = <String, List<MealEntryModel>>{};
    for (var meal in meals) {
      mealsByType.putIfAbsent(meal.mealType, () => []).add(meal);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...mealsByType.entries.map((entry) {
          return _buildMealTypeSection(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildMealTypeSection(String mealType, List<MealEntryModel> meals) {
    final totalCalories = meals.fold<double>(
      0,
      (sum, meal) => sum + (meal.calories * meal.quantity),
    );

    String emoji;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
      case 'petit-déjeuner':
        emoji = '🌅';
        break;
      case 'lunch':
      case 'déjeuner':
        emoji = '🌞';
        break;
      case 'dinner':
      case 'dîner':
        emoji = '🌙';
        break;
      default:
        emoji = '🍴';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          mealType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${totalCalories.round()} calories'),
        children: meals.map((meal) => _buildMealItem(meal)).toList(),
      ),
    );
  }

  Widget _buildMealItem(MealEntryModel meal) {
    return ListTile(
      title: Text(meal.foodName),
      subtitle: Text(
        '${(meal.calories * meal.quantity).round()} cal • ${meal.quantity}x portion',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Supprimer'),
              content: const Text('Voulez-vous supprimer ce repas?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await _foodService.deleteMealEntry(meal.id);
          }
        },
      ),
    );
  }
}