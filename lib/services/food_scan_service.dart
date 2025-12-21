import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';

class FoodScanService {
  static final FoodScanService _instance = FoodScanService._internal();
  factory FoodScanService() => _instance;
  FoodScanService._internal();

  final _prohibitedItems = ['beef', 'pork', 'ham', 'bacon', 'sausage', 'salami', 'prosciutto', 'chorizo', 'pepperoni'];

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
      
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      if (labels.isEmpty) {
        return {
          'success': false,
          'error': 'Could not identify food item',
        };
      }

      String? detectedFood;
      double confidence = 0.0;
      
      for (final label in labels) {
        final lowercaseLabel = label.label.toLowerCase();
        
        if (_prohibitedItems.any((item) => lowercaseLabel.contains(item))) {
          return {
            'success': false,
            'error': 'This item contains beef or pork which is not allowed in FridgeFlow India',
            'isProhibited': true,
          };
        }
        
        if (label.confidence > confidence) {
          detectedFood = label.label;
          confidence = label.confidence;
        }
      }

      if (detectedFood == null || confidence < 0.5) {
        return {
          'success': false,
          'error': 'Could not identify food item with sufficient confidence',
        };
      }

      final category = _categorizeFood(detectedFood);
      final freshnessStatus = _assessFreshness(detectedFood, category);
      final expiryDays = _estimateExpiryDays(category);

      return {
        'success': true,
        'itemName': detectedFood,
        'category': category,
        'freshnessStatus': freshnessStatus,
        'expiryDays': expiryDays,
        'confidence': confidence,
      };
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      return {
        'success': false,
        'error': 'Failed to analyze image: $e',
      };
    }
  }

  FoodCategory _categorizeFood(String foodName) {
    final lower = foodName.toLowerCase();
    
    if (lower.contains('chicken') || lower.contains('turkey') || lower.contains('duck')) {
      return FoodCategory.poultry;
    } else if (lower.contains('mutton') || lower.contains('lamb') || lower.contains('goat')) {
      return FoodCategory.mutton;
    } else if (lower.contains('fish') || lower.contains('salmon') || lower.contains('tuna') || 
               lower.contains('shrimp') || lower.contains('crab') || lower.contains('prawn') ||
               lower.contains('seafood')) {
      return FoodCategory.seafood;
    } else if (lower.contains('milk') || lower.contains('cheese') || lower.contains('yogurt') || 
               lower.contains('butter') || lower.contains('cream') || lower.contains('curd') ||
               lower.contains('paneer') || lower.contains('egg')) {
      return FoodCategory.dairy;
    } else if (lower.contains('vegetable') || lower.contains('fruit') || lower.contains('tomato') ||
               lower.contains('potato') || lower.contains('onion') || lower.contains('carrot') ||
               lower.contains('spinach') || lower.contains('lettuce') || lower.contains('apple') ||
               lower.contains('banana') || lower.contains('orange') || lower.contains('berry')) {
      return FoodCategory.produce;
    } else if (lower.contains('rice') || lower.contains('wheat') || lower.contains('bread') ||
               lower.contains('pasta') || lower.contains('cereal') || lower.contains('oat') ||
               lower.contains('flour') || lower.contains('grain')) {
      return FoodCategory.grains;
    } else if (lower.contains('juice') || lower.contains('soda') || lower.contains('water') ||
               lower.contains('tea') || lower.contains('coffee') || lower.contains('drink')) {
      return FoodCategory.beverages;
    } else if (lower.contains('sauce') || lower.contains('ketchup') || lower.contains('mustard') ||
               lower.contains('mayo') || lower.contains('oil') || lower.contains('vinegar') ||
               lower.contains('spice') || lower.contains('pickle') || lower.contains('chutney')) {
      return FoodCategory.condiments;
    } else if (lower.contains('frozen') || lower.contains('ice')) {
      return FoodCategory.frozen;
    }
    
    return FoodCategory.other;
  }

  FreshnessStatus _assessFreshness(String foodName, FoodCategory category) {
    final lower = foodName.toLowerCase();
    
    if (lower.contains('rotten') || lower.contains('spoiled') || lower.contains('moldy') ||
        lower.contains('expired') || lower.contains('bad') || lower.contains('stale')) {
      return FreshnessStatus.throwAway;
    }
    
    if (lower.contains('wilted') || lower.contains('soft') || lower.contains('overripe')) {
      return FreshnessStatus.useImmediately;
    }
    
    if (category == FoodCategory.produce) {
      if (lower.contains('leafy') || lower.contains('herb') || lower.contains('salad')) {
        return FreshnessStatus.useImmediately;
      }
    }
    
    return FreshnessStatus.fresh;
  }

  int _estimateExpiryDays(FoodCategory category) {
    switch (category) {
      case FoodCategory.produce:
        return 5;
      case FoodCategory.dairy:
        return 7;
      case FoodCategory.poultry:
        return 3;
      case FoodCategory.mutton:
        return 3;
      case FoodCategory.seafood:
        return 2;
      case FoodCategory.grains:
        return 90;
      case FoodCategory.beverages:
        return 30;
      case FoodCategory.condiments:
        return 180;
      case FoodCategory.frozen:
        return 90;
      case FoodCategory.other:
        return 30;
    }
  }

  String getSuggestedEmoji(FoodCategory category) {
    switch (category) {
      case FoodCategory.produce:
        return '🥬';
      case FoodCategory.dairy:
        return '🥛';
      case FoodCategory.poultry:
        return '🍗';
      case FoodCategory.mutton:
        return '🍖';
      case FoodCategory.seafood:
        return '🐟';
      case FoodCategory.grains:
        return '🍚';
      case FoodCategory.beverages:
        return '🧃';
      case FoodCategory.condiments:
        return '🧂';
      case FoodCategory.frozen:
        return '🧊';
      case FoodCategory.other:
        return '📦';
    }
  }
}
