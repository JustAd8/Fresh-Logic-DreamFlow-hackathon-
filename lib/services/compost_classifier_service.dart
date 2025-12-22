import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

enum ProduceSafety {
  safeToEat,
  risky,
  unsafe;

  String get displayName {
    switch (this) {
      case ProduceSafety.safeToEat:
        return 'Safe to Eat';
      case ProduceSafety.risky:
        return 'Borderline - Use Caution';
      case ProduceSafety.unsafe:
        return 'Unsafe - Time to Compost';
    }
  }

  String get icon {
    switch (this) {
      case ProduceSafety.safeToEat:
        return '✓';
      case ProduceSafety.risky:
        return '⚠';
      case ProduceSafety.unsafe:
        return '🗑️';
    }
  }
}

class CompostClassifierService {
  static final CompostClassifierService _instance = CompostClassifierService._internal();
  factory CompostClassifierService() => _instance;
  CompostClassifierService._internal();

  final _rotIndicators = [
    'rotten', 'spoiled', 'moldy', 'mold', 'decay', 'decompose',
    'bad', 'stale', 'expired', 'fermented', 'wilted', 'brown',
    'black', 'mushy', 'slimy', 'fungus', 'bacteria'
  ];

  final _riskyIndicators = [
    'soft', 'overripe', 'bruised', 'spotted', 'wrinkled',
    'discolored', 'dull', 'faded', 'yellowing'
  ];

  Future<Map<String, dynamic>> analyzeProduceSafety(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
      
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      if (labels.isEmpty) {
        return {
          'success': false,
          'error': 'Could not analyze the produce image',
        };
      }

      String produceName = 'Produce';
      ProduceSafety safety = ProduceSafety.safeToEat;
      String recommendation = '';
      List<String> detectedIssues = [];
      
      for (final label in labels) {
        final lowercaseLabel = label.label.toLowerCase();
        
        if (_rotIndicators.any((indicator) => lowercaseLabel.contains(indicator))) {
          safety = ProduceSafety.unsafe;
          detectedIssues.add(label.label);
        } else if (_riskyIndicators.any((indicator) => lowercaseLabel.contains(indicator))) {
          if (safety != ProduceSafety.unsafe) {
            safety = ProduceSafety.risky;
            detectedIssues.add(label.label);
          }
        }
        
        if (label.confidence > 0.6 && _isProduceLabel(lowercaseLabel)) {
          produceName = label.label;
        }
      }

      recommendation = _getRecommendation(safety, produceName);

      return {
        'success': true,
        'produceName': produceName,
        'safety': safety,
        'recommendation': recommendation,
        'detectedIssues': detectedIssues,
      };
    } catch (e) {
      debugPrint('Error analyzing produce safety: $e');
      return {
        'success': false,
        'error': 'Failed to analyze produce: $e',
      };
    }
  }

  bool _isProduceLabel(String label) {
    final produceKeywords = [
      'fruit', 'vegetable', 'tomato', 'potato', 'onion', 'carrot',
      'spinach', 'lettuce', 'apple', 'banana', 'orange', 'berry',
      'avocado', 'mango', 'papaya', 'guava', 'grape', 'cucumber',
      'broccoli', 'cauliflower', 'cabbage', 'pepper', 'chili',
      'melon', 'peach', 'pear', 'plum', 'cherry', 'strawberry',
      'leafy', 'green', 'herb', 'produce'
    ];
    
    return produceKeywords.any((keyword) => label.contains(keyword));
  }

  String _getRecommendation(ProduceSafety safety, String produceName) {
    switch (safety) {
      case ProduceSafety.safeToEat:
        return _getSafeRecommendation(produceName);
      case ProduceSafety.risky:
        return _getRiskyRecommendation(produceName);
      case ProduceSafety.unsafe:
        return 'This $produceName shows signs of rot or decay. Do not consume. Consider composting to enrich soil.';
    }
  }

  String _getSafeRecommendation(String produce) {
    final recommendations = [
      'Looks fresh! Perfect for a salad.',
      'Great condition! Use it in your next recipe.',
      'Fresh and ready to eat!',
      'In good shape! Consider using soon.',
      'Looking good! Add to smoothie or curry.',
    ];
    
    final random = (produce.hashCode % recommendations.length).abs();
    return recommendations[random];
  }

  String _getRiskyRecommendation(String produce) {
    return 'This $produce is borderline. Cook thoroughly (heat kills bacteria). Use today if possible. Not recommended for raw consumption.';
  }
}
