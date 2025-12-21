import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgeflow/models/shopping_cart_model.dart';
import 'package:fridgeflow/models/recipe_model.dart';

class ShoppingCartService {
  static final ShoppingCartService _instance = ShoppingCartService._internal();
  factory ShoppingCartService() => _instance;
  ShoppingCartService._internal();

  static const String _cartKey = 'shopping_cart';
  ShoppingCart? _cart;

  ShoppingCart? get cart => _cart;

  Future<void> initialize(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final decoded = jsonDecode(cartJson);
        final loadedCart = ShoppingCart.fromJson(decoded);
        if (loadedCart.userId == userId) {
          _cart = loadedCart;
        } else {
          _cart = _createEmptyCart(userId);
        }
      } else {
        _cart = _createEmptyCart(userId);
      }
    } catch (e) {
      debugPrint('Failed to load cart: $e');
      _cart = _createEmptyCart(userId);
    }
  }

  ShoppingCart _createEmptyCart(String userId) => ShoppingCart(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: userId,
    items: [],
    status: CartStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Future<void> addItem(String userId, CartItem item) async {
    try {
      if (_cart == null) {
        _cart = _createEmptyCart(userId);
      }

      final existingIndex = _cart!.items.indexWhere((i) => i.name == item.name);
      
      if (existingIndex != -1) {
        final updatedItems = List<CartItem>.from(_cart!.items);
        updatedItems[existingIndex] = CartItem(
          name: item.name,
          quantity: updatedItems[existingIndex].quantity + item.quantity,
          unit: item.unit,
        );
        _cart = _cart!.copyWith(items: updatedItems, updatedAt: DateTime.now());
      } else {
        final updatedItems = List<CartItem>.from(_cart!.items)..add(item);
        _cart = _cart!.copyWith(items: updatedItems, updatedAt: DateTime.now());
      }

      await _saveCart();
    } catch (e) {
      debugPrint('Failed to add item to cart: $e');
      rethrow;
    }
  }

  Future<void> addMissingIngredients(String userId, List<RecipeIngredient> missingIngredients) async {
    try {
      for (final ingredient in missingIngredients) {
        await addItem(
          userId,
          CartItem(
            name: ingredient.name,
            quantity: 1,
            unit: 'unit',
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to add missing ingredients: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String itemName) async {
    try {
      if (_cart != null) {
        final updatedItems = _cart!.items.where((item) => item.name != itemName).toList();
        _cart = _cart!.copyWith(items: updatedItems, updatedAt: DateTime.now());
        await _saveCart();
      }
    } catch (e) {
      debugPrint('Failed to remove item from cart: $e');
      rethrow;
    }
  }

  Future<void> updateItemQuantity(String itemName, int newQuantity) async {
    try {
      if (_cart != null) {
        final updatedItems = _cart!.items.map((item) {
          if (item.name == itemName) {
            return item.copyWith(quantity: newQuantity);
          }
          return item;
        }).toList();
        _cart = _cart!.copyWith(items: updatedItems, updatedAt: DateTime.now());
        await _saveCart();
      }
    } catch (e) {
      debugPrint('Failed to update item quantity: $e');
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      _cart = _createEmptyCart(userId);
      await _saveCart();
    } catch (e) {
      debugPrint('Failed to clear cart: $e');
      rethrow;
    }
  }

  Future<void> markAsOrdered() async {
    try {
      if (_cart != null) {
        _cart = _cart!.copyWith(status: CartStatus.ordered, updatedAt: DateTime.now());
        await _saveCart();
      }
    } catch (e) {
      debugPrint('Failed to mark cart as ordered: $e');
      rethrow;
    }
  }

  String generateDeepLink() {
    if (_cart == null || _cart!.items.isEmpty) {
      return '';
    }

    final itemNames = _cart!.items.map((item) => item.name.replaceAll(' ', '+')).join('+');
    return 'instacart://search?q=$itemNames';
  }

  Future<void> _saveCart() async {
    try {
      if (_cart != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cartKey, jsonEncode(_cart!.toJson()));
      }
    } catch (e) {
      debugPrint('Failed to save cart: $e');
      rethrow;
    }
  }
}
