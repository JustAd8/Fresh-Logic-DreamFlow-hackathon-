import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/services/product_image_service.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  String? _userId;
  List<InventoryItem> _items = [];
  bool _isLoading = false;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    _userId = userId;
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('inventory_$userId');
      
      if (itemsJson != null) {
        final List<dynamic> decoded = jsonDecode(itemsJson);
        _items = decoded.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _items = _generateSampleData(userId);
        await _saveItems();
      }
    } catch (e) {
      debugPrint('Failed to load inventory: $e');
      _items = _generateSampleData(userId);
      await _saveItems();
    } finally {
      _isLoading = false;
    }
  }

  List<InventoryItem> getItemsByUserId(String userId) => _items.where((item) => item.userId == userId).toList();

  List<InventoryItem> getExpiringSoonItems(String userId) =>
      getItemsByUserId(userId).where((item) => item.isExpiringSoon).toList();

  List<InventoryItem> getExpiredItems(String userId) =>
      getItemsByUserId(userId).where((item) => item.isExpired).toList();

  List<InventoryItem> getSortedByExpiry(String userId) {
    final userItems = getItemsByUserId(userId);
    userItems.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return userItems;
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      // Generate product image if not provided
      final imageUrl = item.imageUrl ?? ProductImageService().getProductEmoji(item.itemName, item.category);
      final itemWithImage = item.copyWith(imageUrl: imageUrl);
      
      _items.add(itemWithImage);
      await _saveItems();
      await _syncToFirestore(itemWithImage);
    } catch (e) {
      debugPrint('Failed to add item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(updatedAt: DateTime.now());
        await _saveItems();
        await _syncToFirestore(_items[index]);
      }
    } catch (e) {
      debugPrint('Failed to update item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      _items.removeWhere((item) => item.id == itemId);
      await _saveItems();
      await _deleteFromFirestore(itemId);
    } catch (e) {
      debugPrint('Failed to delete item: $e');
      rethrow;
    }
  }

  Future<void> simulateIoTSync(String userId) async {
    try {
      final newItems = _generateRandomItems(userId, 5);
      _items.addAll(newItems);
      await _saveItems();
      
      // Sync all new items to Firestore
      for (final item in newItems) {
        await _syncToFirestore(item);
      }
    } catch (e) {
      debugPrint('Failed to simulate IoT sync: $e');
      rethrow;
    }
  }

  Future<void> _saveItems() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('inventory_$_userId', itemsJson);
    } catch (e) {
      debugPrint('Failed to save items: $e');
      rethrow;
    }
  }

  List<InventoryItem> _generateSampleData(String userId) {
    final now = DateTime.now();
    return [
      InventoryItem(
        id: '1',
        userId: userId,
        itemName: 'Organic Milk',
        quantity: 1,
        unit: 'liter',
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 2)),
        category: FoodCategory.dairy,
        freshnessStatus: FreshnessStatus.useImmediately,
        imageUrl: 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '2',
        userId: userId,
        itemName: 'Fresh Spinach',
        quantity: 1,
        unit: 'bunch',
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 1)),
        category: FoodCategory.produce,
        freshnessStatus: FreshnessStatus.useImmediately,
        imageUrl: 'assets/images/Spinach_Fresh_Vegetable_null_1766820604286.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '3',
        userId: userId,
        itemName: 'Chicken Breast',
        quantity: 500,
        unit: 'grams',
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 5)),
        category: FoodCategory.poultry,
        freshnessStatus: FreshnessStatus.fresh,
        imageUrl: 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '4',
        userId: userId,
        itemName: 'Paneer',
        quantity: 250,
        unit: 'grams',
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 4)),
        category: FoodCategory.dairy,
        freshnessStatus: FreshnessStatus.fresh,
        imageUrl: 'assets/images/Paneer_Indian_Cheese_null_1766820602470.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '5',
        userId: userId,
        itemName: 'Tomatoes',
        quantity: 6,
        unit: 'pieces',
        purchaseDate: now.subtract(const Duration(days: 4)),
        expiryDate: now.subtract(const Duration(days: 1)),
        category: FoodCategory.produce,
        freshnessStatus: FreshnessStatus.throwAway,
        imageUrl: 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '6',
        userId: userId,
        itemName: 'Onions',
        quantity: 4,
        unit: 'pieces',
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 10)),
        category: FoodCategory.produce,
        freshnessStatus: FreshnessStatus.fresh,
        imageUrl: 'assets/images/Onions_Fresh_Vegetable_null_1766820599636.jpg',
        createdAt: now,
        updatedAt: now,
      ),
      InventoryItem(
        id: '7',
        userId: userId,
        itemName: 'Carrots',
        quantity: 500,
        unit: 'grams',
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 7)),
        category: FoodCategory.produce,
        freshnessStatus: FreshnessStatus.fresh,
        imageUrl: 'assets/images/Carrots_Fresh_Vegetable_null_1766820600559.jpg',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<InventoryItem> _generateRandomItems(String userId, int count) {
    final random = Random();
    final now = DateTime.now();
    final items = <InventoryItem>[];
    
    final sampleItems = [
      ('Paneer', 'assets/images/Paneer_Indian_Cheese_null_1766820602470.jpg', FoodCategory.dairy, 'grams'),
      ('Carrots', 'assets/images/Carrots_Fresh_Vegetable_null_1766820600559.jpg', FoodCategory.produce, 'grams'),
      ('Chicken', 'assets/images/Chicken_Fresh_Meat_null_1766820603461.jpg', FoodCategory.poultry, 'grams'),
      ('Milk', 'assets/images/Milk_Dairy_Product_null_1766820601576.jpg', FoodCategory.dairy, 'liter'),
      ('Tomatoes', 'assets/images/Tomatoes_Fresh_Vegetable_null_1766820598640.jpg', FoodCategory.produce, 'pieces'),
      ('Onions', 'assets/images/Onions_Fresh_Vegetable_null_1766820599636.jpg', FoodCategory.produce, 'pieces'),
      ('Spinach', 'assets/images/Spinach_Fresh_Vegetable_null_1766820604286.jpg', FoodCategory.produce, 'bunch'),
      ('Potatoes', 'assets/images/Potatoes_Fresh_Vegetable_null_1766820605194.jpg', FoodCategory.produce, 'kg'),
    ];

    for (var i = 0; i < count && i < sampleItems.length; i++) {
      final sample = sampleItems[random.nextInt(sampleItems.length)];
      final daysUntilExpiry = random.nextInt(14) + 1;
      
      FreshnessStatus status;
      if (daysUntilExpiry < 0) {
        status = FreshnessStatus.throwAway;
      } else if (daysUntilExpiry <= 2) {
        status = FreshnessStatus.useImmediately;
      } else {
        status = FreshnessStatus.fresh;
      }
      
      items.add(InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        userId: userId,
        itemName: sample.$1,
        quantity: random.nextInt(5) + 1,
        unit: sample.$4,
        purchaseDate: now,
        expiryDate: now.add(Duration(days: daysUntilExpiry)),
        category: sample.$3,
        freshnessStatus: status,
        imageUrl: sample.$2,
        createdAt: now,
        updatedAt: now,
      ));
    }
    
    return items;
  }

  double calculateFreshnessScore(String userId) {
    final userItems = getItemsByUserId(userId);
    if (userItems.isEmpty) return 100.0;

    final expiredCount = userItems.where((item) => item.isExpired).length;
    final expiringSoonCount = userItems.where((item) => item.isExpiringSoon).length;
    final freshCount = userItems.where((item) => item.daysRemaining >= 3).length;

    final score = ((freshCount * 1.0 + expiringSoonCount * 0.5) / userItems.length) * 100;
    return score.clamp(0, 100);
  }

  Future<void> _syncToFirestore(InventoryItem item) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final itemDoc = firestore.collection('inventory').doc(item.id);
      
      await itemDoc.set({
        ...item.toJson(),
        'purchaseDate': Timestamp.fromDate(item.purchaseDate),
        'expiryDate': Timestamp.fromDate(item.expiryDate),
        'createdAt': Timestamp.fromDate(item.createdAt),
        'updatedAt': Timestamp.fromDate(item.updatedAt),
      }, SetOptions(merge: true));
      
      debugPrint('Item synced to Firestore: ${item.id}');
    } catch (e) {
      debugPrint('Failed to sync item to Firestore: $e');
      // Don't rethrow - local storage should still work
    }
  }

  Future<void> _deleteFromFirestore(String itemId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('inventory').doc(itemId).delete();
      debugPrint('Item deleted from Firestore: $itemId');
    } catch (e) {
      debugPrint('Failed to delete item from Firestore: $e');
      // Don't rethrow - local storage should still work
    }
  }
}
