enum CartStatus {
  active,
  ordered;

  String get displayName {
    switch (this) {
      case CartStatus.active:
        return 'Active';
      case CartStatus.ordered:
        return 'Ordered';
    }
  }
}

class CartItem {
  final String name;
  final int quantity;
  final String unit;

  CartItem({
    required this.name,
    required this.quantity,
    this.unit = 'units',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    unit: json['unit'] as String? ?? 'units',
  );

  CartItem copyWith({
    String? name,
    int? quantity,
    String? unit,
  }) => CartItem(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
  );
}

class ShoppingCart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final CartStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingCart({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((e) => e.toJson()).toList(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ShoppingCart.fromJson(Map<String, dynamic> json) => ShoppingCart(
    id: json['id'] as String,
    userId: json['userId'] as String,
    items: (json['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: CartStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CartStatus.active,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  ShoppingCart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    CartStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShoppingCart(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    items: items ?? this.items,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
