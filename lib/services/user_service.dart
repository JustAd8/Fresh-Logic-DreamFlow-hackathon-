import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgeflow/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _userKey = 'current_user';
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Failed to initialize UserService: $e');
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required List<String> dietaryPreferences,
    required List<String> allergies,
  }) async {
    try {
      final now = DateTime.now();
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        dietaryPreferences: dietaryPreferences,
        allergies: allergies,
        createdAt: now,
        updatedAt: now,
      );
      await _saveUser();
    } catch (e) {
      debugPrint('Failed to create user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      _currentUser = user.copyWith(updatedAt: DateTime.now());
      await _saveUser();
    } catch (e) {
      debugPrint('Failed to update user: $e');
      rethrow;
    }
  }

  Future<void> _saveUser() async {
    try {
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      debugPrint('Failed to save user: $e');
      rethrow;
    }
  }

  Future<void> clearUser() async {
    try {
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Failed to clear user: $e');
      rethrow;
    }
  }

  bool get hasUser => _currentUser != null;
}
