import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../services/food_service.dart';
import '../../models/food_model.dart';
import '../../models/meal_entry_model.dart';

class AddMealScreen extends StatefulWidget {
  final String userId;
  final DateTime selectedDate;

  const AddMealScreen({
    Key? key,
    required this.userId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedMealType = 'Petit-déjeuner';
  final List<String> _mealTypes = [
    'Petit-déjeuner',
    'Déjeuner',
    'Dîner',
    'Collation'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un repas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMealType,
                  decoration: InputDecoration(
                    labelText: 'Type de repas',
                    prefixIcon: const Icon(Icons.restaurant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _mealTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedMealType = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher un aliment',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FoodModel>>(
              stream: _foodService.searchFoods(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun aliment trouvé',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final foods = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return _buildFoodItem(food);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodModel food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(food.category),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${food.calories.round()} cal • ${food.servingSize.round()}${food.servingUnit}\n'
          'P: ${food.protein.round()}g • G: ${food.carbs.round()}g • L: ${food.fat.round()}g',
        ),
        trailing: const Icon(Icons.add_circle, color: Colors.green),
        onTap: () => _showQuantityDialog(food),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'légumes':
      case 'vegetables':
        return Icons.eco;
      case 'viande':
      case 'meat':
        return Icons.lunch_dining;
      case 'produits laitiers':
      case 'dairy':
        return Icons.cookie;
      case 'céréales':
      case 'grains':
        return Icons.grain;
      case 'boissons':
      case 'drinks':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  Future<void> _showQuantityDialog(FoodModel food) async {
    double quantity = 1.0;
    final quantityController = TextEditingController(text: '1.0');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter ${food.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité (portions)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                quantity = double.tryParse(value) ?? 1.0;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total: ${(food.calories * quantity).round()} calories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'P: ${(food.protein * quantity).round()}g • '
                    'G: ${(food.carbs * quantity).round()}g • '
                    'L: ${(food.fat * quantity).round()}g',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true) {
      final finalQuantity = double.tryParse(quantityController.text) ?? 1.0;
      await _addMeal(food, finalQuantity);
    }
  }

  Future<void> _addMeal(FoodModel food, double quantity) async {
    try {
      final entry = MealEntryModel(
        id: const Uuid().v4(),
        userId: widget.userId,
        foodId: food.id,
        foodName: food.name,
        calories: food.calories,
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat,
        quantity: quantity,
        mealType: _selectedMealType,
        dateTime: widget.selectedDate,
      );

      await _foodService.addMealEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repas ajouté avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}