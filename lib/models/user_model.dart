class User {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String? photoUrl;
  final String themeMode;
  final String language;
  final String region;
  final String currency;
  final String? currentLocation;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final double totalMoneySaved;
  final Map<String, double> monthlySavings;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.photoUrl,
    this.themeMode = 'system',
    this.language = 'en',
    this.region = 'IN',
    this.currency = 'INR',
    this.currentLocation,
    required this.dietaryPreferences,
    required this.allergies,
    this.totalMoneySaved = 0.0,
    Map<String, double>? monthlySavings,
    required this.createdAt,
    required this.updatedAt,
  }) : monthlySavings = monthlySavings ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'age': age,
    'photoUrl': photoUrl,
    'themeMode': themeMode,
    'language': language,
    'region': region,
    'currency': currency,
    'currentLocation': currentLocation,
    'dietaryPreferences': dietaryPreferences,
    'allergies': allergies,
    'totalMoneySaved': totalMoneySaved,
    'monthlySavings': monthlySavings,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    age: json['age'] as int?,
    photoUrl: json['photoUrl'] as String?,
    themeMode: json['themeMode'] as String? ?? 'system',
    language: json['language'] as String? ?? 'en',
    region: json['region'] as String? ?? 'IN',
    currency: json['currency'] as String? ?? 'INR',
    currentLocation: json['currentLocation'] as String?,
    dietaryPreferences: List<String>.from(json['dietaryPreferences'] as List),
    allergies: List<String>.from(json['allergies'] as List),
    totalMoneySaved: (json['totalMoneySaved'] as num?)?.toDouble() ?? 0.0,
    monthlySavings: (json['monthlySavings'] as Map<String, dynamic>?)?.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    ) ?? {},
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? photoUrl,
    String? themeMode,
    String? language,
    String? region,
    String? currency,
    String? currentLocation,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    double? totalMoneySaved,
    Map<String, double>? monthlySavings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    age: age ?? this.age,
    photoUrl: photoUrl ?? this.photoUrl,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    region: region ?? this.region,
    currency: currency ?? this.currency,
    currentLocation: currentLocation ?? this.currentLocation,
    dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    allergies: allergies ?? this.allergies,
    totalMoneySaved: totalMoneySaved ?? this.totalMoneySaved,
    monthlySavings: monthlySavings ?? this.monthlySavings,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
