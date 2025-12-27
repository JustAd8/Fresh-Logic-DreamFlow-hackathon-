import 'package:flutter/material.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/inventory_service.dart';
import 'package:fridgeflow/utils/responsive_layout.dart';
import 'package:fridgeflow/services/community_rescue_service.dart';
import 'package:fridgeflow/models/community_listing_model.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/theme.dart';
import 'package:intl/intl.dart';

class CommunityRescueScreen extends StatefulWidget {
  const CommunityRescueScreen({super.key});

  @override
  State<CommunityRescueScreen> createState() => _CommunityRescueScreenState();
}

class _CommunityRescueScreenState extends State<CommunityRescueScreen> {
  final _userService = UserService();
  final _inventoryService = InventoryService();
  final _communityService = CommunityRescueService();

  List<CommunityListing> _nearbyListings = [];
  List<CommunityListing> _myListings = [];
  bool _isLoading = true;
  bool _showMyListings = false;

  final double _userLat = 19.0760;
  final double _userLng = 72.8777;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _communityService.initialize();
      final user = _userService.currentUser;
      
      if (user != null) {
        _nearbyListings = _communityService.getNearbyListings(
          userLat: _userLat,
          userLng: _userLng,
          radiusInMiles: 1.0,
        );
        _myListings = _communityService.getListingsByUserId(user.id);
      }
    } catch (e) {
      debugPrint('Error loading community listings: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCreateListingDialog() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final items = _inventoryService.getSortedByExpiry(user.id);
    final expiringSoonItems = items.where((item) => item.isExpiringSoon || item.daysRemaining <= 3).toList();

    if (expiringSoonItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items expiring soon to share')),
        );
      }
      return;
    }

    final selectedItem = await showModalBottomSheet<InventoryItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Item with Neighbors',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an item expiring soon to offer to neighbors within 1 mile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ...expiringSoonItems.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(item.imageUrl ?? '🍽️', style: const TextStyle(fontSize: 32)),
              title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Expires in ${item.daysRemaining} days • ${item.quantity} ${item.unit}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.pop(context, item),
            )),
          ],
        ),
      ),
    );

    if (selectedItem != null && mounted) {
      try {
        await _communityService.createListing(userId: user.id, item: selectedItem);
        await _inventoryService.deleteItem(selectedItem.id);
        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedItem.itemName} shared with neighbors!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () => setState(() => _showMyListings = true),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create listing: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteListing(CommunityListing listing) async {
    try {
      await _communityService.deleteListing(listing.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;
    final displayListings = _showMyListings ? _myListings : _nearbyListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Rescue'),
        actions: [
          IconButton(
            icon: Icon(_showMyListings ? Icons.explore : Icons.person),
            onPressed: () => setState(() => _showMyListings = !_showMyListings),
            tooltip: _showMyListings ? 'Browse Community' : 'My Listings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.volunteer_activism,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Hyper-Local Food Bank',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Share food expiring soon with neighbors within 1 mile. Turn waste into kindness!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showMyListings ? 'My Listings' : 'Available Near You',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_showMyListings)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '1 mile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (displayListings.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            children: [
                              Icon(
                                _showMyListings ? Icons.add_circle_outline : Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showMyListings
                                    ? 'No active listings'
                                    : 'No items available nearby',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_showMyListings) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Share food expiring soon to help your neighbors',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      ...displayListings.map((listing) {
                        final isMyListing = listing.userId == user?.id;
                        final daysRemaining = listing.expiryDate.difference(DateTime.now()).inDays;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: AppSpacing.paddingMd,
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      listing.imageUrl ?? '🍽️',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listing.itemName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${listing.quantity} ${listing.unit} • ${listing.category}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              listing.address,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: daysRemaining < 1
                                                ? Theme.of(context).colorScheme.error
                                                : Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            daysRemaining < 1
                                                ? 'Expires today!'
                                                : 'Expires in $daysRemaining day${daysRemaining == 1 ? '' : 's'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: daysRemaining < 1
                                                  ? Theme.of(context).colorScheme.error
                                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMyListing)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Theme.of(context).colorScheme.error,
                                    onPressed: () => _deleteListing(listing),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Contact feature coming soon!'),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Share Food'),
      ),
    );
  }
}
