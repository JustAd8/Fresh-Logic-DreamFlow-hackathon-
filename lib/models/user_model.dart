class User {
  final String id;
  final String name;
  final String email;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dietaryPreferences,
    required this.allergies,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dietaryPreferences': dietaryPreferences,
    'allergies': allergies,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    dietaryPreferences: List<String>.from(json['dietaryPreferences'] as List),
    allergies: List<String>.from(json['allergies'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    allergies: allergies ?? this.allergies,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
