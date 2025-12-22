import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgeflow/models/recipe_model.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';

class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  String? _userId;
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  Future<void> initialize(String userId) async {
    _userId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString('recipes_$userId');
      
      if (recipesJson != null) {
        final dynamic decoded = jsonDecode(recipesJson);
        if (decoded is List) {
          _recipes = decoded.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to load recipes: $e');
      _recipes = [];
    }
  }

  Future<List<Recipe>> generateRecipes(List<InventoryItem> availableItems) async {
    try {
      final newRecipes = _generateSampleRecipes(availableItems);
      _recipes = newRecipes;
      await _saveRecipes();
      return newRecipes;
    } catch (e) {
      debugPrint('Failed to generate recipes: $e');
      return [];
    }
  }

  List<Recipe> _generateSampleRecipes(List<InventoryItem> availableItems) {
    final availableNames = availableItems.map((e) => e.itemName.toLowerCase()).toSet();
    final now = DateTime.now();
    final random = Random();

    final allRecipes = [
      _createRecipe(
        '1',
        'Butter Chicken Masala',
        [
          RecipeIngredient(name: 'Chicken', quantity: '500g'),
          RecipeIngredient(name: 'Tomatoes', quantity: '4 pieces'),
          RecipeIngredient(name: 'Cream', quantity: '1 cup'),
          RecipeIngredient(name: 'Butter', quantity: '3 tbsp'),
          RecipeIngredient(name: 'Garam Masala', quantity: '2 tsp'),
        ],
        [
          'Marinate chicken with yogurt and spices for 2 hours',
          'Grill or pan-fry chicken until cooked',
          'Make tomato gravy with butter, onions, and tomatoes',
          'Blend the gravy until smooth',
          'Add garam masala and cream',
          'Add grilled chicken and simmer for 10 minutes',
          'Garnish with kasuri methi and serve with naan',
        ],
        40,
        'assets/images/Butter_Chicken_Indian_curry_null_1766363060415.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '2',
        'Vegetable Biryani',
        [
          RecipeIngredient(name: 'Basmati Rice', quantity: '2 cups'),
          RecipeIngredient(name: 'Mixed Vegetables', quantity: '500g'),
          RecipeIngredient(name: 'Onions', quantity: '2 large'),
          RecipeIngredient(name: 'Yogurt', quantity: '1/2 cup'),
          RecipeIngredient(name: 'Biryani Masala', quantity: '3 tbsp'),
        ],
        [
          'Soak basmati rice for 30 minutes',
          'Fry onions until golden brown',
          'Sauté vegetables with biryani masala',
          'Layer rice and vegetables in a pot',
          'Add saffron milk and fried onions on top',
          'Cover and cook on dum for 25 minutes',
          'Serve hot with raita and papadum',
        ],
        50,
        'assets/images/Biryani_Indian_rice_dish_null_1766363061287.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '3',
        'Masala Dosa with Sambar',
        [
          RecipeIngredient(name: 'Dosa Batter', quantity: '2 cups'),
          RecipeIngredient(name: 'Potatoes', quantity: '4 medium'),
          RecipeIngredient(name: 'Onions', quantity: '2 medium'),
          RecipeIngredient(name: 'Mustard Seeds', quantity: '1 tsp'),
          RecipeIngredient(name: 'Curry Leaves', quantity: '10 leaves'),
        ],
        [
          'Boil and mash potatoes',
          'Temper mustard seeds and curry leaves',
          'Sauté onions and add turmeric',
          'Mix with mashed potatoes',
          'Spread dosa batter on hot tawa',
          'Add potato filling and fold',
          'Serve with sambar and coconut chutney',
        ],
        30,
        'assets/images/Masala_Dosa_Indian_breakfast_null_1766363062512.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '4',
        'Paneer Tikka',
        [
          RecipeIngredient(name: 'Paneer', quantity: '400g'),
          RecipeIngredient(name: 'Bell Peppers', quantity: '2 pieces'),
          RecipeIngredient(name: 'Yogurt', quantity: '1 cup'),
          RecipeIngredient(name: 'Tikka Masala', quantity: '3 tbsp'),
          RecipeIngredient(name: 'Lemon Juice', quantity: '2 tbsp'),
        ],
        [
          'Cut paneer and bell peppers into cubes',
          'Mix yogurt with tikka masala and lemon juice',
          'Marinate paneer and peppers for 1 hour',
          'Thread onto skewers',
          'Grill in tandoor or oven at 200°C for 15 minutes',
          'Brush with butter halfway through',
          'Serve hot with mint chutney',
        ],
        25,
        'assets/images/Paneer_Tikka_Indian_appetizer_null_1766363063584.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '5',
        'Chole Bhature',
        [
          RecipeIngredient(name: 'Chickpeas', quantity: '2 cups'),
          RecipeIngredient(name: 'Tomatoes', quantity: '3 pieces'),
          RecipeIngredient(name: 'Onions', quantity: '2 large'),
          RecipeIngredient(name: 'All Purpose Flour', quantity: '2 cups'),
          RecipeIngredient(name: 'Chole Masala', quantity: '3 tbsp'),
        ],
        [
          'Soak chickpeas overnight and pressure cook',
          'Make gravy with onions, tomatoes, and chole masala',
          'Add cooked chickpeas and simmer',
          'Knead flour with yogurt for bhature',
          'Roll into circles and deep fry until puffy',
          'Drain on paper towels',
          'Serve chole with hot bhature and pickles',
        ],
        45,
        'assets/images/Chole_Bhature_Indian_chickpea_curry_null_1766363064431.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '6',
        'Samosa Chaat',
        [
          RecipeIngredient(name: 'Samosas', quantity: '6 pieces'),
          RecipeIngredient(name: 'Chickpeas', quantity: '1 cup'),
          RecipeIngredient(name: 'Yogurt', quantity: '1 cup'),
          RecipeIngredient(name: 'Tamarind Chutney', quantity: '1/2 cup'),
          RecipeIngredient(name: 'Sev', quantity: '1/2 cup'),
        ],
        [
          'Break samosas into pieces',
          'Layer with boiled chickpeas',
          'Drizzle with whisked yogurt',
          'Add tamarind and mint chutney',
          'Top with sev, onions, and coriander',
          'Sprinkle chaat masala',
          'Serve immediately for crispy texture',
        ],
        15,
        'assets/images/Samosa_Indian_snack_null_1766363065491.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '7',
        'Dal Tadka',
        [
          RecipeIngredient(name: 'Yellow Lentils', quantity: '1 cup'),
          RecipeIngredient(name: 'Tomatoes', quantity: '2 pieces'),
          RecipeIngredient(name: 'Onions', quantity: '1 large'),
          RecipeIngredient(name: 'Ghee', quantity: '3 tbsp'),
          RecipeIngredient(name: 'Cumin Seeds', quantity: '1 tsp'),
        ],
        [
          'Wash and pressure cook lentils with turmeric',
          'Mash cooked dal until smooth',
          'Prepare tadka with ghee, cumin, and garlic',
          'Add onions and tomatoes to tadka',
          'Pour tadka over dal',
          'Simmer for 5 minutes',
          'Garnish with coriander and serve with rice',
        ],
        30,
        'assets/images/Dal_Tadka_Indian_lentil_curry_null_1766363066314.png',
        availableNames,
        now,
      ),
      _createRecipe(
        '8',
        'Tandoori Chicken',
        [
          RecipeIngredient(name: 'Chicken Legs', quantity: '6 pieces'),
          RecipeIngredient(name: 'Yogurt', quantity: '1 cup'),
          RecipeIngredient(name: 'Tandoori Masala', quantity: '3 tbsp'),
          RecipeIngredient(name: 'Ginger Garlic Paste', quantity: '2 tbsp'),
          RecipeIngredient(name: 'Lemon Juice', quantity: '3 tbsp'),
        ],
        [
          'Make cuts on chicken pieces',
          'Mix yogurt with all spices and pastes',
          'Marinate chicken for at least 4 hours',
          'Preheat oven to 220°C',
          'Place chicken on a rack',
          'Bake for 35-40 minutes, turning halfway',
          'Serve with onion rings and mint chutney',
        ],
        50,
        'assets/images/Tandoori_Chicken_Indian_grilled_null_1766363067570.jpg',
        availableNames,
        now,
      ),
    ];

    allRecipes.shuffle(random);
    return allRecipes.take(3).toList();
  }

  Recipe _createRecipe(
    String id,
    String title,
    List<RecipeIngredient> ingredients,
    List<String> instructions,
    int cookingTime,
    String heroImage,
    Set<String> availableItems,
    DateTime createdAt,
  ) {
    final updatedIngredients = ingredients.map((ingredient) {
      final isAvailable = availableItems.any(
        (item) => item.toLowerCase().contains(ingredient.name.toLowerCase()) ||
                  ingredient.name.toLowerCase().contains(item.toLowerCase()),
      );
      return ingredient.copyWith(isAvailable: isAvailable);
    }).toList();

    final missing = updatedIngredients.where((i) => !i.isAvailable).toList();
    final available = updatedIngredients.where((i) => i.isAvailable).length;
    final matchScore = updatedIngredients.isEmpty 
        ? 0.0 
        : (available / updatedIngredients.length) * 100;

    final estimatedHomeCost = _calculateHomeCost(ingredients);
    final estimatedRestaurantPrice = _calculateRestaurantPrice(title, estimatedHomeCost);

    return Recipe(
      id: id,
      title: title,
      ingredientsRequired: updatedIngredients,
      missingIngredients: missing,
      instructions: instructions,
      cookingTime: cookingTime,
      heroImage: heroImage,
      matchScore: matchScore,
      estimatedHomeCost: estimatedHomeCost,
      estimatedRestaurantPrice: estimatedRestaurantPrice,
      createdAt: createdAt,
    );
  }

  double _calculateHomeCost(List<RecipeIngredient> ingredients) {
    double total = 0.0;
    for (var ingredient in ingredients) {
      if (ingredient.name.toLowerCase().contains('chicken') || 
          ingredient.name.toLowerCase().contains('mutton')) {
        total += 250.0;
      } else if (ingredient.name.toLowerCase().contains('fish') || 
                 ingredient.name.toLowerCase().contains('seafood')) {
        total += 200.0;
      } else if (ingredient.name.toLowerCase().contains('rice') || 
                 ingredient.name.toLowerCase().contains('pasta')) {
        total += 50.0;
      } else if (ingredient.name.toLowerCase().contains('cheese') || 
                 ingredient.name.toLowerCase().contains('cream')) {
        total += 80.0;
      } else {
        total += 30.0;
      }
    }
    return total;
  }

  double _calculateRestaurantPrice(String title, double homeCost) {
    double multiplier = 3.5;
    if (title.toLowerCase().contains('curry') || title.toLowerCase().contains('mutton')) {
      multiplier = 4.0;
    } else if (title.toLowerCase().contains('pasta') || title.toLowerCase().contains('bowl')) {
      multiplier = 3.0;
    }
    return homeCost * multiplier;
  }

  Future<void> _saveRecipes() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = jsonEncode(_recipes.map((e) => e.toJson()).toList());
      await prefs.setString('recipes_$_userId', recipesJson);
    } catch (e) {
      debugPrint('Failed to save recipes: $e');
      rethrow;
    }
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}
