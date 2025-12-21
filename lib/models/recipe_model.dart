class RecipeIngredient {
  final String name;
  final String quantity;
  final bool isAvailable;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    this.isAvailable = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'isAvailable': isAvailable,
  };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
    name: json['name'] as String,
    quantity: json['quantity'] as String,
    isAvailable: json['isAvailable'] as bool? ?? false,
  );

  RecipeIngredient copyWith({
    String? name,
    String? quantity,
    bool? isAvailable,
  }) => RecipeIngredient(
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

class Recipe {
  final String id;
  final String title;
  final List<RecipeIngredient> ingredientsRequired;
  final List<RecipeIngredient> missingIngredients;
  final List<String> instructions;
  final int cookingTime;
  final String heroImage;
  final double matchScore;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredientsRequired,
    required this.missingIngredients,
    required this.instructions,
    required this.cookingTime,
    required this.heroImage,
    required this.matchScore,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'ingredientsRequired': ingredientsRequired.map((e) => e.toJson()).toList(),
    'missingIngredients': missingIngredients.map((e) => e.toJson()).toList(),
    'instructions': instructions,
    'cookingTime': cookingTime,
    'heroImage': heroImage,
    'matchScore': matchScore,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    title: json['title'] as String,
    ingredientsRequired: (json['ingredientsRequired'] as List)
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList(),
    missingIngredients: (json['missingIngredients'] as List)
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList(),
    instructions: List<String>.from(json['instructions'] as List),
    cookingTime: json['cookingTime'] as int,
    heroImage: json['heroImage'] as String,
    matchScore: (json['matchScore'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Recipe copyWith({
    String? id,
    String? title,
    List<RecipeIngredient>? ingredientsRequired,
    List<RecipeIngredient>? missingIngredients,
    List<String>? instructions,
    int? cookingTime,
    String? heroImage,
    double? matchScore,
    DateTime? createdAt,
  }) => Recipe(
    id: id ?? this.id,
    title: title ?? this.title,
    ingredientsRequired: ingredientsRequired ?? this.ingredientsRequired,
    missingIngredients: missingIngredients ?? this.missingIngredients,
    instructions: instructions ?? this.instructions,
    cookingTime: cookingTime ?? this.cookingTime,
    heroImage: heroImage ?? this.heroImage,
    matchScore: matchScore ?? this.matchScore,
    createdAt: createdAt ?? this.createdAt,
  );
}
