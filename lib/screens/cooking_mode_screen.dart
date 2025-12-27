import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/utils/responsive_layout.dart';
import 'package:fridgeflow/services/recipe_service.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/models/recipe_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class CookingModeScreen extends StatefulWidget {
  final String recipeId;

  const CookingModeScreen({super.key, required this.recipeId});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final _recipeService = RecipeService();
  final _userService = UserService();
  final _tts = FlutterTts();
  final _speech = SpeechToText();
  
  Recipe? _recipe;
  int _currentStep = 0;
  bool _isReading = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  bool _savingsRecorded = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _initTts();
    _initSpeech();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _loadRecipe() {
    _recipe = _recipeService.getRecipeById(widget.recipeId);
    if (_recipe == null && mounted) {
      context.pop();
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _speechEnabled = await _speech.initialize(
          onError: (error) => debugPrint('Speech error: $error'),
          onStatus: (status) => debugPrint('Speech status: $status'),
        );
      }
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
    }
  }

  Future<void> _readAloud() async {
    if (_recipe == null || _currentStep >= _recipe!.instructions.length) return;

    setState(() => _isReading = true);

    try {
      final instruction = _recipe!.instructions[_currentStep];
      final textToRead = 'Step ${_currentStep + 1}. $instruction';
      await _tts.speak(textToRead);
      
      await Future.delayed(Duration(seconds: instruction.length ~/ 10 + 3));
    } catch (e) {
      debugPrint('TTS Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read aloud: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReading = false);
      }
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice recognition not available')),
      );
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        final command = result.recognizedWords.toLowerCase();
        debugPrint('Voice command: $command');

        if (command.contains('next') || command.contains('continue')) {
          _nextStep();
        } else if (command.contains('previous') || command.contains('back')) {
          _previousStep();
        } else if (command.contains('read') || command.contains('repeat')) {
          _readAloud();
        }

        setState(() => _isListening = false);
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _nextStep() {
    if (_recipe != null && _currentStep < _recipe!.instructions.length - 1) {
      setState(() => _currentStep++);
    } else if (_recipe != null && _currentStep == _recipe!.instructions.length - 1) {
      _completeRecipe();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeRecipe() async {
    if (_recipe == null || _savingsRecorded) return;

    try {
      await _userService.addSavings(_recipe!.savingsAmount, _recipe!.title);
      _savingsRecorded = true;

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber, size: 32),
                SizedBox(width: 12),
                Text('Recipe Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations on cooking ${_recipe!.title}!',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💰 Money Saved',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_recipe!.savingsAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'vs. Restaurant: ₹${_recipe!.estimatedRestaurantPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to record savings: $e');
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'voice',
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.secondary,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'read',
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
        ],
      ),
    );
  }
}
