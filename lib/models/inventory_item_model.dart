enum FoodCategory {
  produce,
  dairy,
  poultry,
  mutton,
  seafood,
  grains,
  beverages,
  condiments,
  frozen,
  other;

  String get displayName {
    switch (this) {
      case FoodCategory.produce:
        return 'Produce';
      case FoodCategory.dairy:
        return 'Dairy';
      case FoodCategory.poultry:
        return 'Poultry';
      case FoodCategory.mutton:
        return 'Mutton/Lamb';
      case FoodCategory.seafood:
        return 'Seafood';
      case FoodCategory.grains:
        return 'Grains';
      case FoodCategory.beverages:
        return 'Beverages';
      case FoodCategory.condiments:
        return 'Condiments';
      case FoodCategory.frozen:
        return 'Frozen';
      case FoodCategory.other:
        return 'Other';
    }
  }
}

enum FreshnessStatus {
  fresh,
  useImmediately,
  throwAway;

  String get displayName {
    switch (this) {
      case FreshnessStatus.fresh:
        return 'Fresh';
      case FreshnessStatus.useImmediately:
        return 'Use Immediately';
      case FreshnessStatus.throwAway:
        return 'Throw Away';
    }
  }

  String get icon {
    switch (this) {
      case FreshnessStatus.fresh:
        return '✓';
      case FreshnessStatus.useImmediately:
        return '⚠';
      case FreshnessStatus.throwAway:
        return '✗';
    }
  }
}

class InventoryItem {
  final String id;
  final String userId;
  final String itemName;
  final int quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final FoodCategory category;
  final FreshnessStatus freshnessStatus;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    required this.expiryDate,
    required this.category,
    required this.freshnessStatus,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;

  bool get isExpired => daysRemaining < 0;

  bool get isExpiringSoon => daysRemaining >= 0 && daysRemaining < 3;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemName': itemName,
    'quantity': quantity,
    'unit': unit,
    'purchaseDate': purchaseDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'category': category.name,
    'freshnessStatus': freshnessStatus.name,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    userId: json['userId'] as String,
    itemName: json['itemName'] as String,
    quantity: json['quantity'] as int,
    unit: json['unit'] as String,
    purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    category: FoodCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => FoodCategory.other,
    ),
    freshnessStatus: FreshnessStatus.values.firstWhere(
      (e) => e.name == (json['freshnessStatus'] ?? 'fresh'),
      orElse: () => FreshnessStatus.fresh,
    ),
    imageUrl: json['imageUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  InventoryItem copyWith({
    String? id,
    String? userId,
    String? itemName,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    FoodCategory? category,
    FreshnessStatus? freshnessStatus,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InventoryItem(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemName: itemName ?? this.itemName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    expiryDate: expiryDate ?? this.expiryDate,
    category: category ?? this.category,
    freshnessStatus: freshnessStatus ?? this.freshnessStatus,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
