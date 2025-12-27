import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:fridgeflow/models/price_comparison_model.dart';
import 'package:fridgeflow/models/recipe_model.dart';

class PriceComparisonService {
  static final PriceComparisonService _instance = PriceComparisonService._internal();
  factory PriceComparisonService() => _instance;
  PriceComparisonService._internal();

  // Simulated price database for Indian products (₹)
  // In production, this would be fetched from real-time APIs
  final Map<String, Map<QuickCommercePlatform, double>> _priceDatabase = {
    // Produce
    'tomato': {
      QuickCommercePlatform.swiggyInstamart: 25.0,
      QuickCommercePlatform.zepto: 22.0,
      QuickCommercePlatform.blinkit: 24.0,
    },
    'tomatoes': {
      QuickCommercePlatform.swiggyInstamart: 25.0,
      QuickCommercePlatform.zepto: 22.0,
      QuickCommercePlatform.blinkit: 24.0,
    },
    'onion': {
      QuickCommercePlatform.swiggyInstamart: 30.0,
      QuickCommercePlatform.zepto: 28.0,
      QuickCommercePlatform.blinkit: 32.0,
    },
    'onions': {
      QuickCommercePlatform.swiggyInstamart: 30.0,
      QuickCommercePlatform.zepto: 28.0,
      QuickCommercePlatform.blinkit: 32.0,
    },
    'potato': {
      QuickCommercePlatform.swiggyInstamart: 20.0,
      QuickCommercePlatform.zepto: 18.0,
      QuickCommercePlatform.blinkit: 22.0,
    },
    'potatoes': {
      QuickCommercePlatform.swiggyInstamart: 20.0,
      QuickCommercePlatform.zepto: 18.0,
      QuickCommercePlatform.blinkit: 22.0,
    },
    'spinach': {
      QuickCommercePlatform.swiggyInstamart: 35.0,
      QuickCommercePlatform.zepto: 32.0,
      QuickCommercePlatform.blinkit: 38.0,
    },
    'carrot': {
      QuickCommercePlatform.swiggyInstamart: 40.0,
      QuickCommercePlatform.zepto: 38.0,
      QuickCommercePlatform.blinkit: 42.0,
    },
    'carrots': {
      QuickCommercePlatform.swiggyInstamart: 40.0,
      QuickCommercePlatform.zepto: 38.0,
      QuickCommercePlatform.blinkit: 42.0,
    },
    'ginger': {
      QuickCommercePlatform.swiggyInstamart: 60.0,
      QuickCommercePlatform.zepto: 55.0,
      QuickCommercePlatform.blinkit: 58.0,
    },
    'garlic': {
      QuickCommercePlatform.swiggyInstamart: 80.0,
      QuickCommercePlatform.zepto: 75.0,
      QuickCommercePlatform.blinkit: 82.0,
    },
    'green chili': {
      QuickCommercePlatform.swiggyInstamart: 25.0,
      QuickCommercePlatform.zepto: 22.0,
      QuickCommercePlatform.blinkit: 28.0,
    },
    'green chilies': {
      QuickCommercePlatform.swiggyInstamart: 25.0,
      QuickCommercePlatform.zepto: 22.0,
      QuickCommercePlatform.blinkit: 28.0,
    },
    'coriander': {
      QuickCommercePlatform.swiggyInstamart: 15.0,
      QuickCommercePlatform.zepto: 12.0,
      QuickCommercePlatform.blinkit: 18.0,
    },
    // Dairy
    'milk': {
      QuickCommercePlatform.swiggyInstamart: 60.0,
      QuickCommercePlatform.zepto: 58.0,
      QuickCommercePlatform.blinkit: 62.0,
    },
    'paneer': {
      QuickCommercePlatform.swiggyInstamart: 100.0,
      QuickCommercePlatform.zepto: 95.0,
      QuickCommercePlatform.blinkit: 105.0,
    },
    'curd': {
      QuickCommercePlatform.swiggyInstamart: 45.0,
      QuickCommercePlatform.zepto: 42.0,
      QuickCommercePlatform.blinkit: 48.0,
    },
    'yogurt': {
      QuickCommercePlatform.swiggyInstamart: 45.0,
      QuickCommercePlatform.zepto: 42.0,
      QuickCommercePlatform.blinkit: 48.0,
    },
    'butter': {
      QuickCommercePlatform.swiggyInstamart: 50.0,
      QuickCommercePlatform.zepto: 48.0,
      QuickCommercePlatform.blinkit: 52.0,
    },
    'ghee': {
      QuickCommercePlatform.swiggyInstamart: 180.0,
      QuickCommercePlatform.zepto: 175.0,
      QuickCommercePlatform.blinkit: 185.0,
    },
    'cream': {
      QuickCommercePlatform.swiggyInstamart: 65.0,
      QuickCommercePlatform.zepto: 62.0,
      QuickCommercePlatform.blinkit: 68.0,
    },
    // Proteins
    'chicken': {
      QuickCommercePlatform.swiggyInstamart: 220.0,
      QuickCommercePlatform.zepto: 210.0,
      QuickCommercePlatform.blinkit: 230.0,
    },
    'mutton': {
      QuickCommercePlatform.swiggyInstamart: 550.0,
      QuickCommercePlatform.zepto: 540.0,
      QuickCommercePlatform.blinkit: 560.0,
    },
    'eggs': {
      QuickCommercePlatform.swiggyInstamart: 80.0,
      QuickCommercePlatform.zepto: 75.0,
      QuickCommercePlatform.blinkit: 82.0,
    },
    'fish': {
      QuickCommercePlatform.swiggyInstamart: 350.0,
      QuickCommercePlatform.zepto: 340.0,
      QuickCommercePlatform.blinkit: 360.0,
    },
    // Grains & Pulses
    'rice': {
      QuickCommercePlatform.swiggyInstamart: 70.0,
      QuickCommercePlatform.zepto: 65.0,
      QuickCommercePlatform.blinkit: 75.0,
    },
    'wheat flour': {
      QuickCommercePlatform.swiggyInstamart: 45.0,
      QuickCommercePlatform.zepto: 42.0,
      QuickCommercePlatform.blinkit: 48.0,
    },
    'atta': {
      QuickCommercePlatform.swiggyInstamart: 45.0,
      QuickCommercePlatform.zepto: 42.0,
      QuickCommercePlatform.blinkit: 48.0,
    },
    'lentils': {
      QuickCommercePlatform.swiggyInstamart: 120.0,
      QuickCommercePlatform.zepto: 115.0,
      QuickCommercePlatform.blinkit: 125.0,
    },
    'dal': {
      QuickCommercePlatform.swiggyInstamart: 120.0,
      QuickCommercePlatform.zepto: 115.0,
      QuickCommercePlatform.blinkit: 125.0,
    },
    'chickpeas': {
      QuickCommercePlatform.swiggyInstamart: 90.0,
      QuickCommercePlatform.zepto: 85.0,
      QuickCommercePlatform.blinkit: 95.0,
    },
    // Spices & Condiments
    'turmeric powder': {
      QuickCommercePlatform.swiggyInstamart: 40.0,
      QuickCommercePlatform.zepto: 38.0,
      QuickCommercePlatform.blinkit: 42.0,
    },
    'red chili powder': {
      QuickCommercePlatform.swiggyInstamart: 45.0,
      QuickCommercePlatform.zepto: 42.0,
      QuickCommercePlatform.blinkit: 48.0,
    },
    'coriander powder': {
      QuickCommercePlatform.swiggyInstamart: 35.0,
      QuickCommercePlatform.zepto: 32.0,
      QuickCommercePlatform.blinkit: 38.0,
    },
    'cumin seeds': {
      QuickCommercePlatform.swiggyInstamart: 50.0,
      QuickCommercePlatform.zepto: 48.0,
      QuickCommercePlatform.blinkit: 52.0,
    },
    'garam masala': {
      QuickCommercePlatform.swiggyInstamart: 60.0,
      QuickCommercePlatform.zepto: 55.0,
      QuickCommercePlatform.blinkit: 62.0,
    },
    'salt': {
      QuickCommercePlatform.swiggyInstamart: 20.0,
      QuickCommercePlatform.zepto: 18.0,
      QuickCommercePlatform.blinkit: 22.0,
    },
    'oil': {
      QuickCommercePlatform.swiggyInstamart: 180.0,
      QuickCommercePlatform.zepto: 175.0,
      QuickCommercePlatform.blinkit: 185.0,
    },
    'mustard oil': {
      QuickCommercePlatform.swiggyInstamart: 200.0,
      QuickCommercePlatform.zepto: 195.0,
      QuickCommercePlatform.blinkit: 205.0,
    },
  };

  // Simulate delivery times for each platform
  final Map<QuickCommercePlatform, int> _deliveryTimes = {
    QuickCommercePlatform.swiggyInstamart: 25,
    QuickCommercePlatform.zepto: 15,
    QuickCommercePlatform.blinkit: 20,
  };

  /// Get price comparison for a single product
  Future<ProductPriceComparison> getProductPriceComparison(String productName) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    
    final normalizedName = productName.toLowerCase().trim();
    final prices = <ProductPrice>[];
    
    for (final platform in QuickCommercePlatform.values) {
      final platformPrices = _priceDatabase[normalizedName];
      
      if (platformPrices != null && platformPrices.containsKey(platform)) {
        prices.add(ProductPrice(
          platform: platform,
          price: platformPrices[platform]!,
          isAvailable: true,
          deepLink: _generateDeepLink(platform, productName),
          deliveryTimeMinutes: _deliveryTimes[platform]!,
        ));
      } else {
        // Product not available on this platform
        prices.add(ProductPrice(
          platform: platform,
          price: 0.0,
          isAvailable: false,
          deliveryTimeMinutes: _deliveryTimes[platform]!,
        ));
      }
    }
    
    return ProductPriceComparison(
      productName: productName,
      prices: prices,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get price comparison for multiple products (cart items)
  Future<List<ProductPriceComparison>> getCartPriceComparison(List<String> productNames) async {
    final comparisons = <ProductPriceComparison>[];
    
    for (final productName in productNames) {
      try {
        final comparison = await getProductPriceComparison(productName);
        comparisons.add(comparison);
      } catch (e) {
        debugPrint('Failed to get price comparison for $productName: $e');
      }
    }
    
    return comparisons;
  }

  /// Calculate total cost by platform for a recipe
  Future<RecipeCostComparison> getRecipeCostComparison(Recipe recipe) async {
    final totalCostByPlatform = <QuickCommercePlatform, double>{};
    
    // Initialize totals
    for (final platform in QuickCommercePlatform.values) {
      totalCostByPlatform[platform] = 0.0;
    }
    
    // Get prices for all missing ingredients
    for (final ingredient in recipe.missingIngredients) {
      final comparison = await getProductPriceComparison(ingredient.name);
      
      for (final price in comparison.prices) {
        if (price.isAvailable) {
          totalCostByPlatform[price.platform] = 
              (totalCostByPlatform[price.platform] ?? 0.0) + price.price;
        }
      }
    }
    
    // Find best platform (lowest cost with all items available)
    QuickCommercePlatform? bestPlatform;
    double? lowestCost;
    
    for (final entry in totalCostByPlatform.entries) {
      if (entry.value > 0) {
        if (lowestCost == null || entry.value < lowestCost) {
          lowestCost = entry.value;
          bestPlatform = entry.key;
        }
      }
    }
    
    // Calculate max savings
    final costs = totalCostByPlatform.values.where((c) => c > 0).toList();
    final maxSavings = costs.isEmpty ? 0.0 : costs.reduce(max) - costs.reduce(min);
    
    return RecipeCostComparison(
      recipeId: recipe.id,
      recipeName: recipe.title,
      totalCostByPlatform: totalCostByPlatform,
      bestPlatform: bestPlatform,
      lowestTotalCost: lowestCost,
      maxSavings: maxSavings,
      lastUpdated: DateTime.now(),
    );
  }

  /// Generate deep link for platform
  String _generateDeepLink(QuickCommercePlatform platform, String productName) {
    final encodedName = Uri.encodeComponent(productName);
    
    switch (platform) {
      case QuickCommercePlatform.swiggyInstamart:
        return 'https://www.swiggy.com/instamart/search?q=$encodedName';
      case QuickCommercePlatform.zepto:
        return 'https://www.zeptonow.com/search?query=$encodedName';
      case QuickCommercePlatform.blinkit:
        return 'https://blinkit.com/s/?q=$encodedName';
    }
  }

  /// Get optimal platform for cart (best overall value)
  Future<QuickCommercePlatform?> getOptimalPlatformForCart(List<String> productNames) async {
    final comparisons = await getCartPriceComparison(productNames);
    final totalsByPlatform = <QuickCommercePlatform, double>{};
    final availableCountByPlatform = <QuickCommercePlatform, int>{};
    
    // Initialize
    for (final platform in QuickCommercePlatform.values) {
      totalsByPlatform[platform] = 0.0;
      availableCountByPlatform[platform] = 0;
    }
    
    // Calculate totals
    for (final comparison in comparisons) {
      for (final price in comparison.prices) {
        if (price.isAvailable) {
          totalsByPlatform[price.platform] = 
              (totalsByPlatform[price.platform] ?? 0.0) + price.price;
          availableCountByPlatform[price.platform] = 
              (availableCountByPlatform[price.platform] ?? 0) + 1;
        }
      }
    }
    
    // Find platform with most items available at lowest total cost
    QuickCommercePlatform? bestPlatform;
    double? lowestCost;
    int? mostItems;
    
    for (final platform in QuickCommercePlatform.values) {
      final itemCount = availableCountByPlatform[platform] ?? 0;
      final cost = totalsByPlatform[platform] ?? 0.0;
      
      if (itemCount > 0) {
        if (mostItems == null || itemCount > mostItems || 
            (itemCount == mostItems && (lowestCost == null || cost < lowestCost))) {
          mostItems = itemCount;
          lowestCost = cost;
          bestPlatform = platform;
        }
      }
    }
    
    return bestPlatform;
  }
}
