import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/inventory_service.dart';
import 'package:fridgeflow/services/recipe_service.dart';
import 'package:fridgeflow/widgets/freshness_gauge.dart';
import 'package:fridgeflow/widgets/inventory_item_card.dart';
import 'package:fridgeflow/models/inventory_item_model.dart';
import 'package:fridgeflow/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _userService = UserService();
  final _inventoryService = InventoryService();
  final _recipeService = RecipeService();

  double _freshnessScore = 100.0;
  List<InventoryItem> _expiringSoon = [];
  String _suggestedDinner = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final user = _userService.currentUser;
      if (user == null) return;

      _freshnessScore = _inventoryService.calculateFreshnessScore(user.id);
      _expiringSoon = _inventoryService.getExpiringSoonItems(user.id);

      if (_recipeService.recipes.isNotEmpty) {
        _suggestedDinner = _recipeService.recipes.first.title;
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              user?.name ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          children: [
                            Text(
                              'Pantry Health',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            FreshnessGauge(score: _freshnessScore),
                            const SizedBox(height: 16),
                            Text(
                              _freshnessScore >= 75
                                  ? 'Your pantry is well-stocked and fresh!'
                                  : _freshnessScore >= 50
                                      ? 'Some items need attention soon.'
                                      : 'Time to restock your pantry!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.kitchen_outlined,
                            title: 'Pantry',
                            subtitle:
                                '${_inventoryService.getItemsByUserId(user?.id ?? "").length} items',
                            color: Theme.of(context).colorScheme.primary,
                            onTap: () => context.go('/pantry'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.restaurant_menu,
                            title: 'Recipes',
                            subtitle:
                                '${_recipeService.recipes.length} available',
                            color: Theme.of(context).colorScheme.secondary,
                            onTap: () => context.go('/recipes'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_expiringSoon.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expiring Soon',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go('/pantry'),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._expiringSoon.take(3).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InventoryItemCard(
                              item: item,
                              onTap: () => context.go('/pantry'),
                            ),
                          )),
                    ],
                    if (_suggestedDinner.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: AppSpacing.paddingLg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Suggested Dinner',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _suggestedDinner,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.go('/recipes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                child: const Text('View Recipe'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
