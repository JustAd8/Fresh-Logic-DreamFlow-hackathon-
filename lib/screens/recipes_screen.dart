import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/inventory_service.dart';
import 'package:fridgeflow/services/recipe_service.dart';
import 'package:fridgeflow/services/shopping_cart_service.dart';
import 'package:fridgeflow/widgets/recipe_card.dart';
import 'package:fridgeflow/models/recipe_model.dart';
import 'package:fridgeflow/theme.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _userService = UserService();
  final _inventoryService = InventoryService();
  final _recipeService = RecipeService();
  final _cartService = ShoppingCartService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);

    try {
      _recipes = _recipeService.recipes;
    } catch (e) {
      debugPrint('Error loading recipes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateRecipes() async {
    final user = _userService.currentUser;
    if (user == null) return;

    setState(() => _isGenerating = true);

    try {
      final availableItems = _inventoryService.getItemsByUserId(user.id);
      _recipes = await _recipeService.generateRecipes(availableItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 12),
                const Text('AI recipes generated!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate recipes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(recipe.heroImage, style: const TextStyle(fontSize: 80)),
                  ),
                ),
                Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.cookingTime} minutes',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${recipe.matchScore.toInt()}% Match',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.ingredientsRequired.map((ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  ingredient.isAvailable
                                      ? Icons.check_circle
                                      : Icons.shopping_cart_outlined,
                                  size: 20,
                                  color: ingredient.isAvailable
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${ingredient.quantity} ${ingredient.name}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: ingredient.isAvailable
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.error,
                                      decoration: ingredient.isAvailable
                                          ? null
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (recipe.missingIngredients.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final user = _userService.currentUser;
                              if (user == null) return;

                              await _cartService.addMissingIngredients(
                                user.id,
                                recipe.missingIngredients,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Missing ingredients added to cart!'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add Missing to Cart'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Instructions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/cooking/${recipe.id}');
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Cooking'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...recipe.instructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final instruction = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  instruction,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Engine'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate AI-powered recipes based on your pantry',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateRecipes,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate Recipes'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecipes,
                  child: ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: _recipes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: _isGenerating ? null : _generateRecipes,
                            icon: _isGenerating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(_isGenerating ? 'Generating...' : 'Regenerate Recipes'),
                          ),
                        );
                      }

                      final recipe = _recipes[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RecipeCard(
                          recipe: recipe,
                          onTap: () => _showRecipeDetails(recipe),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
