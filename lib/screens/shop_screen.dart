import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/shopping_cart_service.dart';
import 'package:fridgeflow/services/price_comparison_service.dart';
import 'package:fridgeflow/models/shopping_cart_model.dart';
import 'package:fridgeflow/models/price_comparison_model.dart';
import 'package:fridgeflow/theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _userService = UserService();
  final _cartService = ShoppingCartService();
  final _priceService = PriceComparisonService();

  ShoppingCart? _cart;
  List<ProductPriceComparison> _priceComparisons = [];
  QuickCommercePlatform? _optimalPlatform;
  bool _isLoading = false;
  bool _isLoadingPrices = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    try {
      _cart = _cartService.cart;
      if (_cart != null && _cart!.items.isNotEmpty) {
        await _loadPriceComparisons();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPriceComparisons() async {
    if (_cart == null || _cart!.items.isEmpty) return;

    setState(() => _isLoadingPrices = true);

    try {
      final productNames = _cart!.items.map((item) => item.name).toList();
      _priceComparisons = await _priceService.getCartPriceComparison(productNames);
      _optimalPlatform = await _priceService.getOptimalPlatformForCart(productNames);
    } catch (e) {
      debugPrint('Error loading price comparisons: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrices = false);
      }
    }
  }

  Future<void> _removeItem(String itemName) async {
    try {
      await _cartService.removeItem(itemName);
      await _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    final user = _userService.currentUser;
    if (user == null) return;

    try {
      await _cartService.clearCart(user.id);
      await _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear cart: $e')),
        );
      }
    }
  }

  Future<void> _openPlatform(QuickCommercePlatform platform) async {
    if (_cart == null || _cart!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    try {
      final uri = Uri.parse(platform.baseUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${platform.displayName}...'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${platform.displayName}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open platform: $e')),
        );
      }
    }
  }

  double _getTotalForPlatform(QuickCommercePlatform platform) {
    double total = 0.0;
    for (final comparison in _priceComparisons) {
      final price = comparison.prices.firstWhere(
        (p) => p.platform == platform,
        orElse: () => ProductPrice(
          platform: platform,
          price: 0.0,
          isAvailable: false,
          deliveryTimeMinutes: 0,
        ),
      );
      if (price.isAvailable) {
        total += price.price;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cart?.items ?? [];
    final isEmpty = cartItems.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (!isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add missing ingredients from recipes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: AppSpacing.paddingMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price comparison header
                            if (_isLoadingPrices)
                              Card(
                                child: Padding(
                                  padding: AppSpacing.paddingMd,
                                  child: Row(
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Comparing prices across platforms...',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_optimalPlatform != null)
                              _buildPriceComparisonCard(),
                            
                            const SizedBox(height: 16),
                            
                            // Cart items list
                            Text(
                              'Cart Items (${cartItems.length})',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            ...cartItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final comparison = _priceComparisons.length > index
                                  ? _priceComparisons[index]
                                  : null;
                              
                              return _buildCartItemCard(item, comparison);
                            }),
                          ],
                        ),
                      ),
                    ),
                    
                    // Platform selection bottom sheet
                    _buildPlatformSelectionSheet(),
                  ],
                ),
    );
  }

  Widget _buildPriceComparisonCard() {
    if (_optimalPlatform == null) return const SizedBox.shrink();

    final platforms = QuickCommercePlatform.values;
    final bestTotal = _getTotalForPlatform(_optimalPlatform!);
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.savings_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Best Deal: ${_optimalPlatform!.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Platform comparison
            ...platforms.map((platform) {
              final total = _getTotalForPlatform(platform);
              final isBest = platform == _optimalPlatform;
              final savings = total > bestTotal ? total - bestTotal : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      platform.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        platform.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (isBest)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'BEST',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (savings > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '+₹${savings.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, ProductPriceComparison? comparison) {
    final bestPrice = comparison?.bestPrice;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_basket),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${item.quantity} ${item.unit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bestPrice != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${bestPrice.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => _removeItem(item.name),
                ),
              ],
            ),
            
            if (comparison != null && comparison.maxSavings > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Save up to ₹${comparison.maxSavings.toStringAsFixed(0)} by choosing ${bestPrice?.platform.displayName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelectionSheet() {
    final platforms = QuickCommercePlatform.values;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Platform',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: platforms.map((platform) {
                  final total = _getTotalForPlatform(platform);
                  final isBest = platform == _optimalPlatform;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _openPlatform(platform),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBest
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: isBest
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              platform.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              platform.displayName.split(' ').first,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                                color: isBest
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (total > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '₹${total.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isBest
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
