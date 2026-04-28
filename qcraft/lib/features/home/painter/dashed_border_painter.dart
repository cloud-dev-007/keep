import 'dart:ui';

import 'package:flutter/material.dart';

class DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  DashedRoundedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashLength = 6.0,
    this.gapLength = 4.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round // <== makes line ends rounded
      ..style = PaintingStyle.stroke;

    final RRect rRect = borderRadius.toRRect(Offset.zero & size);
    final Path path = Path()..addRRect(rRect);
    final PathMetrics metrics = path.computeMetrics();

    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = distance + dashLength;
        final Path dashPath = metric.extractPath(
          distance,
          end.clamp(0.0, metric.length),
        );
        canvas.drawPath(dashPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
