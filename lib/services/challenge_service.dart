import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgeflow/models/challenge_model.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/services/inventory_service.dart';

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  String? _userId;
  List<Challenge> _challenges = [];

  List<Challenge> get challenges => _challenges;
  Challenge? get activeChallenge => _challenges.where((c) => c.status == ChallengeStatus.active).isNotEmpty 
      ? _challenges.firstWhere((c) => c.status == ChallengeStatus.active) 
      : null;

  Future<void> initialize(String userId) async {
    _userId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = prefs.getString('challenges_$userId');
      
      if (challengesJson != null) {
        final List<dynamic> decoded = jsonDecode(challengesJson);
        _challenges = decoded.map((e) => Challenge.fromJson(e as Map<String, dynamic>)).toList();
        
        await _checkExpiredChallenges();
      }
    } catch (e) {
      debugPrint('Failed to load challenges: $e');
      _challenges = [];
    }
  }

  Future<Challenge> createChallenge(String userId) async {
    try {
      final inventoryService = InventoryService();
      final atRiskItems = inventoryService.getExpiringSoonItems(userId);
      
      if (atRiskItems.isEmpty) {
        throw Exception('No at-risk items available for challenge');
      }

      final random = Random();
      final selectedItems = <InventoryItem>[];
      final availableItems = List<InventoryItem>.from(atRiskItems);
      
      final count = min(3, availableItems.length);
      for (int i = 0; i < count; i++) {
        final item = availableItems.removeAt(random.nextInt(availableItems.length));
        selectedItems.add(item);
      }

      final now = DateTime.now();
      final challenge = Challenge(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'Iron Chef Challenge: ${selectedItems.map((e) => e.itemName).join(', ')}',
        targetIngredients: selectedItems,
        startTime: now,
        deadline: now.add(const Duration(hours: 2)),
        status: ChallengeStatus.active,
        createdAt: now,
      );

      _challenges.add(challenge);
      await _saveChallenges();
      
      return challenge;
    } catch (e) {
      debugPrint('Failed to create challenge: $e');
      rethrow;
    }
  }

  Future<void> completeChallenge(String challengeId, String recipeId) async {
    try {
      final index = _challenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _challenges[index] = _challenges[index].copyWith(
          status: ChallengeStatus.completed,
          completedRecipeId: recipeId,
        );
        await _saveChallenges();
      }
    } catch (e) {
      debugPrint('Failed to complete challenge: $e');
      rethrow;
    }
  }

  Future<void> _checkExpiredChallenges() async {
    bool hasChanges = false;
    
    for (int i = 0; i < _challenges.length; i++) {
      if (_challenges[i].status == ChallengeStatus.active && _challenges[i].isExpired) {
        _challenges[i] = _challenges[i].copyWith(status: ChallengeStatus.failed);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await _saveChallenges();
    }
  }

  Future<void> _saveChallenges() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = jsonEncode(_challenges.map((e) => e.toJson()).toList());
      await prefs.setString('challenges_$_userId', challengesJson);
    } catch (e) {
      debugPrint('Failed to save challenges: $e');
      rethrow;
    }
  }

  List<Challenge> getChallengeHistory(String userId) =>
      _challenges.where((c) => c.userId == userId && c.status != ChallengeStatus.active).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
