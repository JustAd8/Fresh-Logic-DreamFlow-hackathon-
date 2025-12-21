import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Circular progress indicator showing pantry health score
class FreshnessGauge extends StatelessWidget {
  final double score;
  final double size;

  const FreshnessGauge({
    super.key,
    required this.score,
    this.size = 160,
  });

  Color _getScoreColor(BuildContext context) {
    if (score >= 75) {
      return Theme.of(context).colorScheme.primary;
    } else if (score >= 50) {
      return const Color(0xFFFFA726);
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  String _getScoreLabel() {
    if (score >= 75) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 25) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _FreshnessGaugePainter(
              progress: score / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: _getScoreColor(context),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toInt()}%',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getScoreLabel(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FreshnessGaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;

  _FreshnessGaugePainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_FreshnessGaugePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor;
}
