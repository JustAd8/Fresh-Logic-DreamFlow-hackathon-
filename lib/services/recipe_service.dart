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
        'Protein-Rich Paneer Tikka Masala',
        [
          RecipeIngredient(name: 'Paneer', quantity: '400g'),
          RecipeIngredient(name: 'Tomatoes', quantity: '4 pieces'),
          RecipeIngredient(name: 'Onions', quantity: '2 medium'),
          RecipeIngredient(name: 'Low-fat Yogurt', quantity: '1/2 cup'),
          RecipeIngredient(name: 'Garam Masala', quantity: '2 tsp'),
        ],
        [
          'Marinate paneer cubes with yogurt, turmeric, and tikka spices for 30 minutes',
          'Grill paneer until golden brown edges appear',
          'Sauté onions and tomatoes until soft',
          'Blend into smooth gravy, add minimal oil',
          'Add grilled paneer and simmer for 10 minutes',
          'Garnish with fresh coriander',
          'Serve with whole wheat roti or brown rice',
        ],
        35,
        'assets/images/Paneer_Tikka_Masala_null_1766820589514.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '2',
        'Hearty Dal Tadka',
        [
          RecipeIngredient(name: 'Yellow Lentils', quantity: '1 cup'),
          RecipeIngredient(name: 'Tomatoes', quantity: '2 pieces'),
          RecipeIngredient(name: 'Onions', quantity: '1 large'),
          RecipeIngredient(name: 'Ghee', quantity: '1 tbsp'),
          RecipeIngredient(name: 'Cumin Seeds', quantity: '1 tsp'),
        ],
        [
          'Wash and pressure cook lentils with turmeric until soft',
          'Mash cooked dal until creamy texture',
          'Prepare tadka with ghee, cumin, and garlic',
          'Add onions and tomatoes to tadka',
          'Pour tadka over dal and mix well',
          'Simmer for 5 minutes on low heat',
          'Garnish with coriander and serve with brown rice',
        ],
        25,
        'assets/images/Dal_Tadka_Lentils_null_1766820590453.png',
        availableNames,
        now,
      ),
      _createRecipe(
        '3',
        'Wholesome Vegetable Biryani',
        [
          RecipeIngredient(name: 'Brown Basmati Rice', quantity: '2 cups'),
          RecipeIngredient(name: 'Mixed Vegetables', quantity: '500g'),
          RecipeIngredient(name: 'Onions', quantity: '2 large'),
          RecipeIngredient(name: 'Low-fat Yogurt', quantity: '1/2 cup'),
          RecipeIngredient(name: 'Biryani Masala', quantity: '2 tbsp'),
        ],
        [
          'Soak brown basmati rice for 30 minutes',
          'Lightly sauté onions until translucent',
          'Cook vegetables with biryani masala',
          'Layer rice and vegetables in a pot',
          'Add saffron milk and yogurt on top',
          'Cover and cook on dum for 30 minutes',
          'Serve hot with cucumber raita',
        ],
        45,
        'assets/images/Vegetable_Biryani_Rice_null_1766820591380.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '4',
        'Iron-Rich Palak Paneer',
        [
          RecipeIngredient(name: 'Spinach', quantity: '500g'),
          RecipeIngredient(name: 'Paneer', quantity: '250g'),
          RecipeIngredient(name: 'Onions', quantity: '1 large'),
          RecipeIngredient(name: 'Tomatoes', quantity: '2 medium'),
          RecipeIngredient(name: 'Ginger Garlic', quantity: '2 tsp'),
        ],
        [
          'Blanch spinach in boiling water for 2 minutes',
          'Blend spinach into smooth puree',
          'Sauté onions, tomatoes, and ginger-garlic',
          'Add spinach puree and cook for 10 minutes',
          'Add paneer cubes and simmer gently',
          'Season with garam masala',
          'Serve with whole wheat roti',
        ],
        30,
        'assets/images/Palak_Paneer_Spinach_null_1766820592323.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '5',
        'High-Fiber Chana Masala',
        [
          RecipeIngredient(name: 'Chickpeas', quantity: '2 cups'),
          RecipeIngredient(name: 'Tomatoes', quantity: '3 pieces'),
          RecipeIngredient(name: 'Onions', quantity: '2 medium'),
          RecipeIngredient(name: 'Chole Masala', quantity: '2 tbsp'),
          RecipeIngredient(name: 'Ginger', quantity: '1 inch'),
        ],
        [
          'Soak chickpeas overnight and pressure cook until tender',
          'Prepare gravy with onions, tomatoes, and spices',
          'Add cooked chickpeas and simmer for 15 minutes',
          'Mash a few chickpeas to thicken gravy',
          'Season with chole masala and amchur',
          'Garnish with fresh coriander',
          'Serve with brown rice or whole wheat kulcha',
        ],
        40,
        'assets/images/Chana_Masala_Chickpeas_null_1766820593279.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '6',
        'Low-Calorie Aloo Gobi',
        [
          RecipeIngredient(name: 'Cauliflower', quantity: '1 medium head'),
          RecipeIngredient(name: 'Potatoes', quantity: '2 medium'),
          RecipeIngredient(name: 'Tomatoes', quantity: '2 pieces'),
          RecipeIngredient(name: 'Turmeric', quantity: '1 tsp'),
          RecipeIngredient(name: 'Cumin Seeds', quantity: '1 tsp'),
        ],
        [
          'Cut cauliflower and potatoes into medium florets',
          'Temper cumin seeds in minimal oil',
          'Add vegetables and turmeric',
          'Cover and cook on low heat until tender',
          'Add tomatoes and cook until soft',
          'Season with cumin powder and coriander',
          'Serve hot with roti or as side dish',
        ],
        25,
        'assets/images/Aloo_Gobi_Cauliflower_null_1766820594187.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '7',
        'Grilled Tandoori Chicken',
        [
          RecipeIngredient(name: 'Chicken', quantity: '500g'),
          RecipeIngredient(name: 'Low-fat Yogurt', quantity: '1 cup'),
          RecipeIngredient(name: 'Tandoori Masala', quantity: '2 tbsp'),
          RecipeIngredient(name: 'Ginger Garlic Paste', quantity: '2 tbsp'),
          RecipeIngredient(name: 'Lemon Juice', quantity: '2 tbsp'),
        ],
        [
          'Make cuts on chicken pieces for better marination',
          'Mix yogurt with spices, ginger-garlic, and lemon',
          'Marinate chicken for minimum 3 hours',
          'Preheat oven to 200°C or prepare grill',
          'Grill chicken until fully cooked, no oil needed',
          'Turn pieces every 10 minutes for even cooking',
          'Serve with mint chutney and salad',
        ],
        45,
        'assets/images/Tandoori_Chicken_Indian_null_1766820595030.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '8',
        'Nutritious Malai Kofta',
        [
          RecipeIngredient(name: 'Paneer', quantity: '200g'),
          RecipeIngredient(name: 'Potatoes', quantity: '2 medium'),
          RecipeIngredient(name: 'Tomatoes', quantity: '4 pieces'),
          RecipeIngredient(name: 'Cashews', quantity: '10 pieces'),
          RecipeIngredient(name: 'Low-fat Cream', quantity: '2 tbsp'),
        ],
        [
          'Boil and mash potatoes, mix with grated paneer',
          'Shape into small balls and shallow fry until golden',
          'Prepare tomato-cashew gravy by blending',
          'Cook gravy with minimal oil until thick',
          'Add koftas just before serving',
          'Drizzle with low-fat cream',
          'Garnish with kasuri methi and serve hot',
        ],
        40,
        'assets/images/Malai_Kofta_Curry_null_1766820595975.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '9',
        'South Indian Sambar',
        [
          RecipeIngredient(name: 'Toor Dal', quantity: '1 cup'),
          RecipeIngredient(name: 'Mixed Vegetables', quantity: '2 cups'),
          RecipeIngredient(name: 'Tomatoes', quantity: '2 pieces'),
          RecipeIngredient(name: 'Tamarind', quantity: '1 lemon-sized'),
          RecipeIngredient(name: 'Sambar Powder', quantity: '2 tbsp'),
        ],
        [
          'Pressure cook toor dal until soft and mushy',
          'Boil vegetables with tamarind water',
          'Add sambar powder and tomatoes',
          'Mix cooked dal with vegetables',
          'Prepare tadka with mustard, curry leaves',
          'Pour tadka over sambar',
          'Serve hot with idli, dosa, or rice',
        ],
        35,
        'assets/images/Sambar_South_Indian_null_1766820596819.jpg',
        availableNames,
        now,
      ),
      _createRecipe(
        '10',
        'Comfort Food Khichdi',
        [
          RecipeIngredient(name: 'Rice', quantity: '1 cup'),
          RecipeIngredient(name: 'Yellow Lentils', quantity: '1/2 cup'),
          RecipeIngredient(name: 'Mixed Vegetables', quantity: '1 cup'),
          RecipeIngredient(name: 'Turmeric', quantity: '1/2 tsp'),
          RecipeIngredient(name: 'Ghee', quantity: '1 tsp'),
        ],
        [
          'Wash rice and lentils together thoroughly',
          'Pressure cook with vegetables and turmeric',
          'Cook until soft and porridge-like consistency',
          'Prepare tadka with cumin and ghee',
          'Pour over khichdi and mix gently',
          'Season with salt to taste',
          'Serve hot with yogurt and papad',
        ],
        25,
        'assets/images/Khichdi_Rice_Lentil_null_1766820597767.jpg',
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
