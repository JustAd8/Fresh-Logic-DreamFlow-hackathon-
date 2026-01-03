import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      await _syncToFirestore();
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

  Future<void> _syncToFirestore() async {
    if (_currentUser == null) return;
    
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(_currentUser!.id);
      
      await userDoc.set({
        ..._currentUser!.toJson(),
        'createdAt': Timestamp.fromDate(_currentUser!.createdAt),
        'updatedAt': Timestamp.fromDate(_currentUser!.updatedAt),
      }, SetOptions(merge: true));
      
      debugPrint('User synced to Firestore: ${_currentUser!.id}');
    } catch (e) {
      debugPrint('Failed to sync user to Firestore: $e');
      // Don't rethrow - local storage should still work
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

  Future<void> addSavings(double amount, String recipeTitle) async {
    if (_currentUser == null) return;
    
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      
      final updatedMonthlySavings = Map<String, double>.from(_currentUser!.monthlySavings);
      updatedMonthlySavings[monthKey] = (updatedMonthlySavings[monthKey] ?? 0.0) + amount;
      
      _currentUser = _currentUser!.copyWith(
        totalMoneySaved: _currentUser!.totalMoneySaved + amount,
        monthlySavings: updatedMonthlySavings,
        updatedAt: DateTime.now(),
      );
      
      await _saveUser();
      await _syncToFirestore();
      debugPrint('Added savings: ₹$amount for $recipeTitle');
    } catch (e) {
      debugPrint('Failed to add savings: $e');
      rethrow;
    }
  }

  double getMonthlySavings(DateTime month) {
    if (_currentUser == null) return 0.0;
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return _currentUser!.monthlySavings[monthKey] ?? 0.0;
  }

  List<MapEntry<String, double>> getRecentMonthlySavings({int months = 6}) {
    if (_currentUser == null) return [];
    
    final now = DateTime.now();
    final recentMonths = <MapEntry<String, double>>[];
    
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final savings = _currentUser!.monthlySavings[monthKey] ?? 0.0;
      recentMonths.add(MapEntry(monthKey, savings));
    }
    
    return recentMonths;
  }

  Future<String?> uploadProfilePhoto(Uint8List photoBytes, String fileName) async {
    if (_currentUser == null) return null;
    
    try {
      debugPrint('Uploading profile photo: $fileName');
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('user_photos/${_currentUser!.id}/$fileName');
      
      final uploadTask = await ref.putData(
        photoBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('Photo uploaded successfully: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Failed to upload profile photo: $e');
      rethrow;
    }
  }

  Future<void> deleteProfilePhoto() async {
    if (_currentUser == null || _currentUser!.photoUrl == null) return;
    
    try {
      debugPrint('Deleting profile photo');
      final storage = FirebaseStorage.instance;
      final ref = storage.refFromURL(_currentUser!.photoUrl!);
      await ref.delete();
      
      final updatedUser = _currentUser!.copyWith(photoUrl: '');
      await updateUser(updatedUser);
      
      debugPrint('Photo deleted successfully');
    } catch (e) {
      debugPrint('Failed to delete profile photo: $e');
      rethrow;
    }
  }
}
