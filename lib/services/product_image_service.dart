import 'package:fridgeflow/models/inventory_item_model.dart';

class ProductImageService {
  static final ProductImageService _instance = ProductImageService._internal();
  factory ProductImageService() => _instance;
  ProductImageService._internal();

  /// Generate appropriate image URL based on product name and category
  String getImageForProduct(String itemName, FoodCategory category) {
    final normalizedName = itemName.toLowerCase().trim();
    
    // Category-based mapping
    final Map<FoodCategory, Map<String, String>> categoryImageMap = {
      FoodCategory.produce: {
        'tomato': '🍅',
        'potato': '🥔',
        'carrot': '🥕',
        'onion': '🧅',
        'broccoli': '🥦',
        'lettuce': '🥬',
        'spinach': '🥬',
        'pepper': '🫑',
        'cucumber': '🥒',
        'eggplant': '🍆',
        'corn': '🌽',
        'garlic': '🧄',
        'banana': '🍌',
        'apple': '🍎',
        'orange': '🍊',
        'lemon': '🍋',
        'mango': '🥭',
        'grapes': '🍇',
        'watermelon': '🍉',
        'default': '🥗'
      },
      FoodCategory.dairy: {
        'milk': '🥛',
        'cheese': '🧀',
        'butter': '🧈',
        'yogurt': '🥛',
        'cream': '🥛',
        'paneer': '🧀',
        'default': '🥛'
      },
      FoodCategory.poultry: {
        'chicken': '🍗',
        'turkey': '🍗',
        'egg': '🥚',
        'default': '🍗'
      },
      FoodCategory.mutton: {
        'mutton': '🍖',
        'lamb': '🍖',
        'goat': '🍖',
        'default': '🍖'
      },
      FoodCategory.seafood: {
        'fish': '🐟',
        'shrimp': '🦐',
        'prawn': '🦐',
        'crab': '🦀',
        'lobster': '🦞',
        'default': '🐟'
      },
      FoodCategory.grains: {
        'rice': '🍚',
        'bread': '🍞',
        'pasta': '🍝',
        'wheat': '🌾',
        'oats': '🌾',
        'default': '🌾'
      },
      FoodCategory.beverages: {
        'juice': '🧃',
        'coffee': '☕',
        'tea': '🍵',
        'water': '💧',
        'soda': '🥤',
        'default': '🧃'
      },
      FoodCategory.condiments: {
        'sauce': '🥫',
        'ketchup': '🥫',
        'mustard': '🥫',
        'mayo': '🥫',
        'oil': '🫒',
        'default': '🥫'
      },
      FoodCategory.frozen: {
        'ice cream': '🍦',
        'frozen': '❄️',
        'default': '❄️'
      },
    };

    // Try to find specific match in category
    final categoryMap = categoryImageMap[category];
    if (categoryMap != null) {
      for (var entry in categoryMap.entries) {
        if (entry.key != 'default' && normalizedName.contains(entry.key)) {
          return entry.value;
        }
      }
      return categoryMap['default'] ?? '🍽️';
    }

    return '🍽️';
  }

  /// Get product image emoji or return default
  String getProductEmoji(String itemName, FoodCategory category) {
    return getImageForProduct(itemName, category);
  }
}
