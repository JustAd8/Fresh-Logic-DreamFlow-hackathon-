import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/services/recipe_service.dart';
import 'package:fridgeflow/models/recipe_model.dart';

class CookingModeScreen extends StatefulWidget {
  final String recipeId;

  const CookingModeScreen({super.key, required this.recipeId});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final _recipeService = RecipeService();
  Recipe? _recipe;
  int _currentStep = 0;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    _recipe = _recipeService.getRecipeById(widget.recipeId);
    if (_recipe == null && mounted) {
      context.pop();
    }
  }

  Future<void> _readAloud() async {
    if (_recipe == null) return;

    setState(() => _isReading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isReading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.volume_up, color: Colors.white),
              SizedBox(width: 12),
              Text('Text-to-speech integration placeholder'),
            ],
          ),
        ),
      );
    }
  }

  void _nextStep() {
    if (_recipe != null && _currentStep < _recipe!.instructions.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final instruction = _recipe!.instructions[_currentStep];
    final totalSteps = _recipe!.instructions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe!.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of $totalSteps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _recipe!.heroImage,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    instruction,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total time: ${_recipe!.cookingTime} min',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentStep > 0 ? _previousStep : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentStep < totalSteps - 1 ? _nextStep : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            _currentStep == totalSteps - 1 ? 'Done' : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isReading ? null : _readAloud,
        icon: _isReading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.volume_up),
        label: Text(_isReading ? 'Reading...' : 'Read Aloud'),
      ),
    );
  }
}
