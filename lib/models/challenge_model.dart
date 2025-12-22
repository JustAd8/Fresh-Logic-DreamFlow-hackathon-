import 'package:fridgeflow/models/inventory_item_model.dart';

enum ChallengeStatus {
  active,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.failed:
        return 'Failed';
    }
  }
}

class Challenge {
  final String id;
  final String userId;
  final String title;
  final List<InventoryItem> targetIngredients;
  final DateTime startTime;
  final DateTime deadline;
  final ChallengeStatus status;
  final String? completedRecipeId;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetIngredients,
    required this.startTime,
    required this.deadline,
    required this.status,
    this.completedRecipeId,
    required this.createdAt,
  });

  Duration get timeRemaining => deadline.difference(DateTime.now());
  
  bool get isExpired => DateTime.now().isAfter(deadline);
  
  String get formattedTimeRemaining {
    if (isExpired) return 'Expired';
    final duration = timeRemaining;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'targetIngredients': targetIngredients.map((e) => e.toJson()).toList(),
    'startTime': startTime.toIso8601String(),
    'deadline': deadline.toIso8601String(),
    'status': status.name,
    'completedRecipeId': completedRecipeId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'] as String,
    userId: json['userId'] as String,
    title: json['title'] as String,
    targetIngredients: (json['targetIngredients'] as List)
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    startTime: DateTime.parse(json['startTime'] as String),
    deadline: DateTime.parse(json['deadline'] as String),
    status: ChallengeStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ChallengeStatus.active,
    ),
    completedRecipeId: json['completedRecipeId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Challenge copyWith({
    String? id,
    String? userId,
    String? title,
    List<InventoryItem>? targetIngredients,
    DateTime? startTime,
    DateTime? deadline,
    ChallengeStatus? status,
    String? completedRecipeId,
    DateTime? createdAt,
  }) => Challenge(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    targetIngredients: targetIngredients ?? this.targetIngredients,
    startTime: startTime ?? this.startTime,
    deadline: deadline ?? this.deadline,
    status: status ?? this.status,
    completedRecipeId: completedRecipeId ?? this.completedRecipeId,
    createdAt: createdAt ?? this.createdAt,
  );
}
