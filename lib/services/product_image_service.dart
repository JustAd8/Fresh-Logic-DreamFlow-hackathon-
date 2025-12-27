import 'package:fridgeflow/models/inventory_item_model.dart';

class ProductImageService {
  static final ProductImageService _instance = ProductImageService._internal();
  factory ProductImageService() => _instance;
  ProductImageService._internal();

  /// Generate appropriate stock image URL based on product name and category
  String getImageForProduct(String itemName, FoodCategory category) {
    final normalizedName = itemName.toLowerCase().trim();
    
    // Category-based mapping to stock images
    final Map<FoodCategory, Map<String, String>> categoryImageMap = {
      FoodCategory.produce: {
        'tomato': 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg',
        'onion': 'assets/images/Onions_Fresh_Vegetable_null_1766820599636.jpg',
        'carrot': 'assets/images/Carrots_Fresh_Vegetable_null_1766820600559.jpg',
        'potato': 'assets/images/Potatoes_Fresh_Vegetable_null_1766820605194.jpg',
        'spinach': 'assets/images/Spinach_Fresh_Vegetable_null_1766820604286.jpg',
        'default': 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg'
      },
      FoodCategory.dairy: {
        'milk': 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg',
        'paneer': 'assets/images/Paneer_Indian_Cheese_null_1766820602470.jpg',
        'cheese': 'assets/images/Paneer_Indian_Cheese_null_1766820602470.jpg',
        'yogurt': 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg',
        'default': 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg'
      },
      FoodCategory.poultry: {
        'chicken': 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg',
        'default': 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg'
      },
      FoodCategory.mutton: {
        'default': 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg'
      },
      FoodCategory.seafood: {
        'default': 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg'
      },
      FoodCategory.grains: {
        'default': 'assets/images/Khichdi_Rice_Lentil_null_1766820597767.jpg'
      },
      FoodCategory.beverages: {
        'default': 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg'
      },
      FoodCategory.condiments: {
        'default': 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg'
      },
      FoodCategory.frozen: {
        'default': 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg'
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
      return categoryMap['default'] ?? 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg';
    }

    return 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg';
  }

  /// Get product image emoji or return default
  String getProductEmoji(String itemName, FoodCategory category) {
    return getImageForProduct(itemName, category);
  }
}
