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
        'Creamy Spinach Chicken',
        [
          RecipeIngredient(name: 'Chicken Breast', quantity: '2 lbs'),
          RecipeIngredient(name: 'Fresh Spinach', quantity: '1 bunch'),
          RecipeIngredient(name: 'Heavy Cream', quantity: '1 cup'),
          RecipeIngredient(name: 'Garlic', quantity: '3 cloves'),
        ],
        [
          'Season chicken with salt and pepper',
          'Pan-sear chicken until golden brown (5-6 min per side)',
          'Remove chicken and sauté garlic in same pan',
          'Add spinach and cook until wilted',
          'Pour in heavy cream and simmer for 5 minutes',
          'Return chicken to pan and cook for 2 more minutes',
          'Serve hot with your favorite side',
        ],
        30,
        '🍗',
        availableNames,
        now,
      ),
      _createRecipe(
        '2',
        'Tomato Basil Pasta',
        [
          RecipeIngredient(name: 'Pasta', quantity: '1 lb'),
          RecipeIngredient(name: 'Tomatoes', quantity: '6 pieces'),
          RecipeIngredient(name: 'Fresh Basil', quantity: '1 bunch'),
          RecipeIngredient(name: 'Olive Oil', quantity: '3 tbsp'),
          RecipeIngredient(name: 'Parmesan Cheese', quantity: '1/2 cup'),
        ],
        [
          'Boil pasta according to package directions',
          'Dice tomatoes and roughly chop basil',
          'Heat olive oil in a large pan',
          'Add tomatoes and cook for 5 minutes',
          'Drain pasta and add to tomato mixture',
          'Toss with basil and parmesan',
          'Season with salt and pepper to taste',
        ],
        20,
        '🍝',
        availableNames,
        now,
      ),
      _createRecipe(
        '3',
        'Healthy Rice Bowl',
        [
          RecipeIngredient(name: 'Brown Rice', quantity: '2 cups cooked'),
          RecipeIngredient(name: 'Eggs', quantity: '2 pieces'),
          RecipeIngredient(name: 'Carrots', quantity: '1/2 lb'),
          RecipeIngredient(name: 'Spinach', quantity: '1 cup'),
          RecipeIngredient(name: 'Soy Sauce', quantity: '2 tbsp'),
        ],
        [
          'Cook brown rice according to package',
          'Julienne carrots and sauté until tender',
          'Wilt spinach in the same pan',
          'Fry eggs to your preference',
          'Assemble bowl with rice, vegetables, and egg',
          'Drizzle with soy sauce',
          'Optional: add sesame seeds and hot sauce',
        ],
        25,
        '🍚',
        availableNames,
        now,
      ),
      _createRecipe(
        '4',
        'Mutton Curry',
        [
          RecipeIngredient(name: 'Mutton', quantity: '1 lb'),
          RecipeIngredient(name: 'Onions', quantity: '2 large'),
          RecipeIngredient(name: 'Tomatoes', quantity: '3 pieces'),
          RecipeIngredient(name: 'Ginger Garlic Paste', quantity: '2 tbsp'),
          RecipeIngredient(name: 'Curry Spices', quantity: '2 tbsp'),
        ],
        [
          'Marinate mutton with spices for 30 minutes',
          'Sauté onions until golden brown',
          'Add ginger garlic paste and cook for 2 minutes',
          'Add tomatoes and cook until soft',
          'Add marinated mutton and sear',
          'Add water and pressure cook for 20 minutes',
          'Garnish with coriander and serve hot',
        ],
        45,
        '🍖',
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

    return Recipe(
      id: id,
      title: title,
      ingredientsRequired: updatedIngredients,
      missingIngredients: missing,
      instructions: instructions,
      cookingTime: cookingTime,
      heroImage: heroImage,
      matchScore: matchScore,
      createdAt: createdAt,
    );
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
