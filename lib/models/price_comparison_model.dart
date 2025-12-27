enum QuickCommercePlatform {
  swiggyInstamart,
  zepto,
  blinkit;

  String get displayName {
    switch (this) {
      case QuickCommercePlatform.swiggyInstamart:
        return 'Swiggy Instamart';
      case QuickCommercePlatform.zepto:
        return 'Zepto';
      case QuickCommercePlatform.blinkit:
        return 'Blinkit';
    }
  }

  String get icon {
    switch (this) {
      case QuickCommercePlatform.swiggyInstamart:
        return '🛒';
      case QuickCommercePlatform.zepto:
        return '⚡';
      case QuickCommercePlatform.blinkit:
        return '🛍️';
    }
  }

  String get baseUrl {
    switch (this) {
      case QuickCommercePlatform.swiggyInstamart:
        return 'https://www.swiggy.com/instamart';
      case QuickCommercePlatform.zepto:
        return 'https://www.zeptonow.com';
      case QuickCommercePlatform.blinkit:
        return 'https://blinkit.com';
    }
  }
}

class ProductPrice {
  final QuickCommercePlatform platform;
  final double price;
  final bool isAvailable;
  final String? deepLink;
  final int deliveryTimeMinutes;

  ProductPrice({
    required this.platform,
    required this.price,
    required this.isAvailable,
    this.deepLink,
    required this.deliveryTimeMinutes,
  });

  Map<String, dynamic> toJson() => {
    'platform': platform.name,
    'price': price,
    'isAvailable': isAvailable,
    'deepLink': deepLink,
    'deliveryTimeMinutes': deliveryTimeMinutes,
  };

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
    platform: QuickCommercePlatform.values.firstWhere(
      (e) => e.name == json['platform'],
      orElse: () => QuickCommercePlatform.swiggyInstamart,
    ),
    price: (json['price'] as num).toDouble(),
    isAvailable: json['isAvailable'] as bool,
    deepLink: json['deepLink'] as String?,
    deliveryTimeMinutes: json['deliveryTimeMinutes'] as int,
  );

  ProductPrice copyWith({
    QuickCommercePlatform? platform,
    double? price,
    bool? isAvailable,
    String? deepLink,
    int? deliveryTimeMinutes,
  }) => ProductPrice(
    platform: platform ?? this.platform,
    price: price ?? this.price,
    isAvailable: isAvailable ?? this.isAvailable,
    deepLink: deepLink ?? this.deepLink,
    deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
  );
}

class ProductPriceComparison {
  final String productName;
  final List<ProductPrice> prices;
  final DateTime lastUpdated;

  ProductPriceComparison({
    required this.productName,
    required this.prices,
    required this.lastUpdated,
  });

  ProductPrice? get bestPrice {
    final availablePrices = prices.where((p) => p.isAvailable).toList();
    if (availablePrices.isEmpty) return null;
    
    availablePrices.sort((a, b) => a.price.compareTo(b.price));
    return availablePrices.first;
  }

  double get maxSavings {
    final availablePrices = prices.where((p) => p.isAvailable).toList();
    if (availablePrices.isEmpty) return 0.0;
    
    final priceValues = availablePrices.map((p) => p.price).toList();
    return priceValues.reduce((a, b) => a > b ? a : b) - priceValues.reduce((a, b) => a < b ? a : b);
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'prices': prices.map((e) => e.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory ProductPriceComparison.fromJson(Map<String, dynamic> json) => ProductPriceComparison(
    productName: json['productName'] as String,
    prices: (json['prices'] as List)
        .map((e) => ProductPrice.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );

  ProductPriceComparison copyWith({
    String? productName,
    List<ProductPrice>? prices,
    DateTime? lastUpdated,
  }) => ProductPriceComparison(
    productName: productName ?? this.productName,
    prices: prices ?? this.prices,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

class RecipeCostComparison {
  final String recipeId;
  final String recipeName;
  final Map<QuickCommercePlatform, double> totalCostByPlatform;
  final QuickCommercePlatform? bestPlatform;
  final double? lowestTotalCost;
  final double? maxSavings;
  final DateTime lastUpdated;

  RecipeCostComparison({
    required this.recipeId,
    required this.recipeName,
    required this.totalCostByPlatform,
    this.bestPlatform,
    this.lowestTotalCost,
    this.maxSavings,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'recipeId': recipeId,
    'recipeName': recipeName,
    'totalCostByPlatform': totalCostByPlatform.map((k, v) => MapEntry(k.name, v)),
    'bestPlatform': bestPlatform?.name,
    'lowestTotalCost': lowestTotalCost,
    'maxSavings': maxSavings,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory RecipeCostComparison.fromJson(Map<String, dynamic> json) => RecipeCostComparison(
    recipeId: json['recipeId'] as String,
    recipeName: json['recipeName'] as String,
    totalCostByPlatform: (json['totalCostByPlatform'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        QuickCommercePlatform.values.firstWhere((e) => e.name == k),
        (v as num).toDouble(),
      ),
    ),
    bestPlatform: json['bestPlatform'] != null
        ? QuickCommercePlatform.values.firstWhere((e) => e.name == json['bestPlatform'])
        : null,
    lowestTotalCost: (json['lowestTotalCost'] as num?)?.toDouble(),
    maxSavings: (json['maxSavings'] as num?)?.toDouble(),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );
}
