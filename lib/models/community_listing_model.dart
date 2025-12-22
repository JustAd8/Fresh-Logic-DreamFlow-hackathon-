class CommunityListing {
  final String id;
  final String userId;
  final String itemId;
  final String itemName;
  final String? imageUrl;
  final int quantity;
  final String unit;
  final DateTime expiryDate;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityListing({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemName,
    this.imageUrl,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemId': itemId,
    'itemName': itemName,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'unit': unit,
    'expiryDate': expiryDate.toIso8601String(),
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CommunityListing.fromJson(Map<String, dynamic> json) => CommunityListing(
    id: json['id'] as String,
    userId: json['userId'] as String,
    itemId: json['itemId'] as String,
    itemName: json['itemName'] as String,
    imageUrl: json['imageUrl'] as String?,
    quantity: json['quantity'] as int,
    unit: json['unit'] as String,
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    category: json['category'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    address: json['address'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  CommunityListing copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? itemName,
    String? imageUrl,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    String? category,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CommunityListing(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemId: itemId ?? this.itemId,
    itemName: itemName ?? this.itemName,
    imageUrl: imageUrl ?? this.imageUrl,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiryDate: expiryDate ?? this.expiryDate,
    category: category ?? this.category,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
