import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:fridgeflow/models/user_model.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/models/community_listing_model.dart';
import 'package:fridgeflow/models/recipe_model.dart';
import 'package:fridgeflow/models/shopping_cart_model.dart';

class AdminExportService {
  static final AdminExportService _instance = AdminExportService._internal();
  factory AdminExportService() => _instance;
  AdminExportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Admin password - Change this to your secure password
  static const String _adminPassword = 'FridgeFlow2024!';

  bool validatePassword(String password) => password == _adminPassword;

  /// Export all users data to CSV format
  Future<String> exportUsersToCSV() async {
    try {
      debugPrint('Exporting users data...');
      final snapshot = await _firestore.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('No users found in Firestore');
        return '';
      }

      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'User ID',
        'Name',
        'Email',
        'Age',
        'Language',
        'Region',
        'Currency',
        'Current Location',
        'Dietary Preferences',
        'Allergies',
        'Total Money Saved',
        'Monthly Savings (JSON)',
        'Created At',
        'Updated At',
      ]);

      // Data rows
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final user = User.fromJson({
            ...data,
            'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
            'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
          });

          rows.add([
            user.id,
            user.name,
            user.email,
            user.age ?? '',
            user.language,
            user.region,
            user.currency,
            user.currentLocation ?? '',
            user.dietaryPreferences.join('; '),
            user.allergies.join('; '),
            user.totalMoneySaved,
            jsonEncode(user.monthlySavings),
            user.createdAt.toIso8601String(),
            user.updatedAt.toIso8601String(),
          ]);
        } catch (e) {
          debugPrint('Error parsing user doc ${doc.id}: $e');
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      debugPrint('Users export completed: ${snapshot.docs.length} users');
      return csv;
    } catch (e) {
      debugPrint('Failed to export users: $e');
      rethrow;
    }
  }

  /// Export all inventory items to CSV format
  Future<String> exportInventoryToCSV() async {
    try {
      debugPrint('Exporting inventory data...');
      final snapshot = await _firestore.collection('inventory').get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('No inventory items found in Firestore');
        return '';
      }

      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Item ID',
        'User ID',
        'Item Name',
        'Quantity',
        'Unit',
        'Purchase Date',
        'Expiry Date',
        'Category',
        'Freshness Status',
        'Image URL',
        'Days Remaining',
        'Created At',
        'Updated At',
      ]);

      // Data rows
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final item = InventoryItem.fromJson({
            ...data,
            'purchaseDate': (data['purchaseDate'] as Timestamp).toDate().toIso8601String(),
            'expiryDate': (data['expiryDate'] as Timestamp).toDate().toIso8601String(),
            'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
            'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
          });

          rows.add([
            item.id,
            item.userId,
            item.itemName,
            item.quantity,
            item.unit,
            item.purchaseDate.toIso8601String(),
            item.expiryDate.toIso8601String(),
            item.category.displayName,
            item.freshnessStatus.displayName,
            item.imageUrl ?? '',
            item.daysRemaining,
            item.createdAt.toIso8601String(),
            item.updatedAt.toIso8601String(),
          ]);
        } catch (e) {
          debugPrint('Error parsing inventory doc ${doc.id}: $e');
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      debugPrint('Inventory export completed: ${snapshot.docs.length} items');
      return csv;
    } catch (e) {
      debugPrint('Failed to export inventory: $e');
      rethrow;
    }
  }

  /// Export all community listings to CSV format
  Future<String> exportCommunityListingsToCSV() async {
    try {
      debugPrint('Exporting community listings data...');
      final snapshot = await _firestore.collection('community_listings').get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('No community listings found in Firestore');
        return '';
      }

      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Listing ID',
        'User ID',
        'Item ID',
        'Item Name',
        'Image URL',
        'Quantity',
        'Unit',
        'Expiry Date',
        'Category',
        'Latitude',
        'Longitude',
        'Address',
        'Created At',
        'Updated At',
      ]);

      // Data rows
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final listing = CommunityListing.fromJson({
            ...data,
            'expiryDate': (data['expiryDate'] as Timestamp).toDate().toIso8601String(),
            'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
            'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
          });

          rows.add([
            listing.id,
            listing.userId,
            listing.itemId,
            listing.itemName,
            listing.imageUrl ?? '',
            listing.quantity,
            listing.unit,
            listing.expiryDate.toIso8601String(),
            listing.category,
            listing.latitude,
            listing.longitude,
            listing.address,
            listing.createdAt.toIso8601String(),
            listing.updatedAt.toIso8601String(),
          ]);
        } catch (e) {
          debugPrint('Error parsing community listing doc ${doc.id}: $e');
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      debugPrint('Community listings export completed: ${snapshot.docs.length} listings');
      return csv;
    } catch (e) {
      debugPrint('Failed to export community listings: $e');
      rethrow;
    }
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final usersCount = (await _firestore.collection('users').get()).docs.length;
      final inventoryCount = (await _firestore.collection('inventory').get()).docs.length;
      final communityCount = (await _firestore.collection('community_listings').get()).docs.length;

      return {
        'users': usersCount,
        'inventory': inventoryCount,
        'community_listings': communityCount,
      };
    } catch (e) {
      debugPrint('Failed to get database stats: $e');
      return {
        'users': 0,
        'inventory': 0,
        'community_listings': 0,
      };
    }
  }

  /// Export all data in a combined format
  Future<Map<String, String>> exportAllData() async {
    try {
      debugPrint('Starting full database export...');
      
      final results = <String, String>{};
      
      results['users'] = await exportUsersToCSV();
      results['inventory'] = await exportInventoryToCSV();
      results['community_listings'] = await exportCommunityListingsToCSV();

      debugPrint('Full database export completed');
      return results;
    } catch (e) {
      debugPrint('Failed to export all data: $e');
      rethrow;
    }
  }

  /// Download CSV file (web-compatible)
  String downloadCSV(String csvData, String filename) {
    try {
      // For web, create a data URL
      final bytes = utf8.encode(csvData);
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:text/csv;charset=utf-8;base64,$base64Data';
      
      debugPrint('Generated download URL for $filename');
      return dataUrl;
    } catch (e) {
      debugPrint('Failed to generate download URL: $e');
      rethrow;
    }
  }
}
