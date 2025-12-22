import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridgeflow/models/community_listing_model.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';

class CommunityRescueService {
  static final CommunityRescueService _instance = CommunityRescueService._internal();
  factory CommunityRescueService() => _instance;
  CommunityRescueService._internal();

  List<CommunityListing> _listings = [];
  bool _isLoading = false;

  List<CommunityListing> get listings => _listings;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final listingsJson = prefs.getString('community_listings');
      
      if (listingsJson != null) {
        final List<dynamic> decoded = jsonDecode(listingsJson);
        _listings = decoded.map((e) => CommunityListing.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _listings = _generateSampleListings();
        await _saveListings();
      }
    } catch (e) {
      debugPrint('Failed to load community listings: $e');
      _listings = _generateSampleListings();
      await _saveListings();
    } finally {
      _isLoading = false;
    }
  }

  Future<CommunityListing> createListing({
    required String userId,
    required InventoryItem item,
  }) async {
    try {
      final now = DateTime.now();
      final simulatedLocation = _getRandomLocationInMumbai();
      
      final listing = CommunityListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        itemId: item.id,
        itemName: item.itemName,
        imageUrl: item.imageUrl,
        quantity: item.quantity,
        unit: item.unit,
        expiryDate: item.expiryDate,
        category: item.category.displayName,
        latitude: simulatedLocation['lat']!,
        longitude: simulatedLocation['lng']!,
        address: simulatedLocation['address']!,
        createdAt: now,
        updatedAt: now,
      );

      _listings.add(listing);
      await _saveListings();
      
      debugPrint('Created community listing: ${listing.itemName}');
      return listing;
    } catch (e) {
      debugPrint('Failed to create listing: $e');
      rethrow;
    }
  }

  Future<void> deleteListing(String listingId) async {
    try {
      _listings.removeWhere((listing) => listing.id == listingId);
      await _saveListings();
    } catch (e) {
      debugPrint('Failed to delete listing: $e');
      rethrow;
    }
  }

  List<CommunityListing> getNearbyListings({
    required double userLat,
    required double userLng,
    double radiusInMiles = 1.0,
  }) {
    return _listings.where((listing) {
      final distance = _calculateDistance(userLat, userLng, listing.latitude, listing.longitude);
      return distance <= radiusInMiles;
    }).toList()
      ..sort((a, b) {
        final distA = _calculateDistance(userLat, userLng, a.latitude, a.longitude);
        final distB = _calculateDistance(userLat, userLng, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
  }

  List<CommunityListing> getListingsByUserId(String userId) => _listings.where((listing) => listing.userId == userId).toList();

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusMiles = 3958.8;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusMiles * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  Map<String, dynamic> _getRandomLocationInMumbai() {
    final random = Random();
    final baseLatMumbai = 19.0760;
    final baseLngMumbai = 72.8777;
    final radiusMiles = 1.0;
    final radiusDegrees = radiusMiles / 69.0;
    
    final lat = baseLatMumbai + (random.nextDouble() * 2 - 1) * radiusDegrees;
    final lng = baseLngMumbai + (random.nextDouble() * 2 - 1) * radiusDegrees;
    
    final neighborhoods = [
      'Andheri West', 'Bandra', 'Juhu', 'Powai', 'Goregaon',
      'Malad', 'Kandivali', 'Borivali', 'Santacruz', 'Vile Parle'
    ];
    
    final address = '${neighborhoods[random.nextInt(neighborhoods.length)]}, Mumbai';
    
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  Future<void> _saveListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listingsJson = jsonEncode(_listings.map((e) => e.toJson()).toList());
      await prefs.setString('community_listings', listingsJson);
    } catch (e) {
      debugPrint('Failed to save listings: $e');
      rethrow;
    }
  }

  List<CommunityListing> _generateSampleListings() {
    final now = DateTime.now();
    final baseLatMumbai = 19.0760;
    final baseLngMumbai = 72.8777;
    
    return [
      CommunityListing(
        id: '1',
        userId: 'sample_user_1',
        itemId: 'sample_1',
        itemName: 'Fresh Mangoes',
        imageUrl: '🥭',
        quantity: 5,
        unit: 'pieces',
        expiryDate: now.add(const Duration(days: 1)),
        category: 'Produce',
        latitude: baseLatMumbai + 0.005,
        longitude: baseLngMumbai + 0.005,
        address: 'Bandra West, Mumbai',
        createdAt: now,
        updatedAt: now,
      ),
      CommunityListing(
        id: '2',
        userId: 'sample_user_2',
        itemId: 'sample_2',
        itemName: 'Whole Wheat Bread',
        imageUrl: '🍞',
        quantity: 1,
        unit: 'loaf',
        expiryDate: now.add(const Duration(days: 2)),
        category: 'Grains',
        latitude: baseLatMumbai - 0.008,
        longitude: baseLngMumbai - 0.003,
        address: 'Andheri East, Mumbai',
        createdAt: now,
        updatedAt: now,
      ),
      CommunityListing(
        id: '3',
        userId: 'sample_user_3',
        itemId: 'sample_3',
        itemName: 'Paneer',
        imageUrl: '🧀',
        quantity: 500,
        unit: 'grams',
        expiryDate: now.add(const Duration(hours: 20)),
        category: 'Dairy',
        latitude: baseLatMumbai + 0.012,
        longitude: baseLngMumbai - 0.007,
        address: 'Juhu, Mumbai',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
