import 'package:fridgeflow/models/inventory_item_model.dart';

enum MacroNutrient {
  carbs,
  protein,
  fats,
  fiber,
  vitamins;

  String get displayName {
    switch (this) {
      case MacroNutrient.carbs:
        return 'Carbohydrates';
      case MacroNutrient.protein:
        return 'Protein';
      case MacroNutrient.fats:
        return 'Healthy Fats';
      case MacroNutrient.fiber:
        return 'Fiber';
      case MacroNutrient.vitamins:
        return 'Vitamins & Minerals';
    }
  }

  String get icon {
    switch (this) {
      case MacroNutrient.carbs:
        return '🍚';
      case MacroNutrient.protein:
        return '🥩';
      case MacroNutrient.fats:
        return '🥑';
      case MacroNutrient.fiber:
        return '🥦';
      case MacroNutrient.vitamins:
        return '🍊';
    }
  }
}

class NutritionProfile {
  final double carbs;
  final double protein;
  final double fats;
  final double fiber;
  final double vitamins;

  NutritionProfile({
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.fiber,
    required this.vitamins,
  });

  double get total => carbs + protein + fats + fiber + vitamins;

  Map<MacroNutrient, double> toPercentages() {
    if (total == 0) {
      return {
        MacroNutrient.carbs: 0,
        MacroNutrient.protein: 0,
        MacroNutrient.fats: 0,
        MacroNutrient.fiber: 0,
        MacroNutrient.vitamins: 0,
      };
    }
    
    return {
      MacroNutrient.carbs: (carbs / total) * 100,
      MacroNutrient.protein: (protein / total) * 100,
      MacroNutrient.fats: (fats / total) * 100,
      MacroNutrient.fiber: (fiber / total) * 100,
      MacroNutrient.vitamins: (vitamins / total) * 100,
    };
  }
}

class NutritionAnalyzerService {
  static final NutritionAnalyzerService _instance = NutritionAnalyzerService._internal();
  factory NutritionAnalyzerService() => _instance;
  NutritionAnalyzerService._internal();

  NutritionProfile analyzePantry(List<InventoryItem> items) {
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFats = 0;
    double totalFiber = 0;
    double totalVitamins = 0;

    for (final item in items) {
      final itemNutrition = _getItemNutrition(item);
      totalCarbs += itemNutrition.carbs * item.quantity;
      totalProtein += itemNutrition.protein * item.quantity;
      totalFats += itemNutrition.fats * item.quantity;
      totalFiber += itemNutrition.fiber * item.quantity;
      totalVitamins += itemNutrition.vitamins * item.quantity;
    }

    return NutritionProfile(
      carbs: totalCarbs,
      protein: totalProtein,
      fats: totalFats,
      fiber: totalFiber,
      vitamins: totalVitamins,
    );
  }

  NutritionProfile _getItemNutrition(InventoryItem item) {
    switch (item.category) {
      case FoodCategory.produce:
        return NutritionProfile(
          carbs: 3.0,
          protein: 1.0,
          fats: 0.5,
          fiber: 4.0,
          vitamins: 5.0,
        );
      
      case FoodCategory.dairy:
        return NutritionProfile(
          carbs: 2.0,
          protein: 4.0,
          fats: 3.0,
          fiber: 0.0,
          vitamins: 2.0,
        );
      
      case FoodCategory.poultry:
        return NutritionProfile(
          carbs: 0.0,
          protein: 8.0,
          fats: 2.0,
          fiber: 0.0,
          vitamins: 1.0,
        );
      
      case FoodCategory.mutton:
        return NutritionProfile(
          carbs: 0.0,
          protein: 7.0,
          fats: 4.0,
          fiber: 0.0,
          vitamins: 1.5,
        );
      
      case FoodCategory.seafood:
        return NutritionProfile(
          carbs: 0.0,
          protein: 9.0,
          fats: 3.5,
          fiber: 0.0,
          vitamins: 2.5,
        );
      
      case FoodCategory.grains:
        return NutritionProfile(
          carbs: 8.0,
          protein: 2.0,
          fats: 0.5,
          fiber: 2.0,
          vitamins: 1.0,
        );
      
      case FoodCategory.beverages:
        return NutritionProfile(
          carbs: 2.0,
          protein: 0.5,
          fats: 0.0,
          fiber: 0.0,
          vitamins: 1.5,
        );
      
      case FoodCategory.condiments:
        return NutritionProfile(
          carbs: 1.0,
          protein: 0.5,
          fats: 2.0,
          fiber: 0.5,
          vitamins: 0.5,
        );
      
      case FoodCategory.frozen:
        return NutritionProfile(
          carbs: 3.0,
          protein: 2.0,
          fats: 1.0,
          fiber: 1.5,
          vitamins: 2.0,
        );
      
      case FoodCategory.other:
        return NutritionProfile(
          carbs: 2.0,
          protein: 1.0,
          fats: 1.0,
          fiber: 1.0,
          vitamins: 1.0,
        );
    }
  }

  String getRecommendation(NutritionProfile profile) {
    final percentages = profile.toPercentages();
    final List<String> recommendations = [];

    if (percentages[MacroNutrient.carbs]! > 50) {
      recommendations.add('Your pantry is high in carbohydrates (${percentages[MacroNutrient.carbs]!.toStringAsFixed(0)}%). Consider adding more protein sources.');
    }

    if (percentages[MacroNutrient.protein]! < 15) {
      recommendations.add('Your pantry is low in protein (${percentages[MacroNutrient.protein]!.toStringAsFixed(0)}%). Consider buying more paneer, tofu, chicken, or lentils.');
    }

    if (percentages[MacroNutrient.fiber]! < 10) {
      recommendations.add('Low fiber content (${percentages[MacroNutrient.fiber]!.toStringAsFixed(0)}%). Add more vegetables, fruits, and whole grains.');
    }

    if (percentages[MacroNutrient.vitamins]! < 15) {
      recommendations.add('Limited vitamins and minerals (${percentages[MacroNutrient.vitamins]!.toStringAsFixed(0)}%). Stock up on fresh produce and leafy greens.');
    }

    if (percentages[MacroNutrient.fats]! < 10) {
      recommendations.add('Low healthy fats (${percentages[MacroNutrient.fats]!.toStringAsFixed(0)}%). Consider adding nuts, seeds, or healthy oils.');
    }

    if (recommendations.isEmpty) {
      return 'Your pantry has a well-balanced nutritional profile! Keep up the good variety.';
    }

    return recommendations.join('\n\n');
  }

  String getBalanceEmoji(NutritionProfile profile) {
    final percentages = profile.toPercentages();
    final carbRatio = percentages[MacroNutrient.carbs]!;
    final proteinRatio = percentages[MacroNutrient.protein]!;
    
    if (carbRatio > 50 && proteinRatio < 15) {
      return '⚠️';
    } else if (carbRatio >= 30 && carbRatio <= 50 && proteinRatio >= 15) {
      return '✅';
    } else {
      return '📊';
    }
  }
}
