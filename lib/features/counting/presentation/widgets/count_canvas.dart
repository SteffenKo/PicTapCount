import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../photos/domain/models/point.dart';

class CountCanvasPainter extends CustomPainter {
  final List<Point> points;
  final ui.Size imageSize;
  final double dotRadius;
  final Matrix4 transform;
  final Color color;

  CountCanvasPainter({
    required this.points,
    required this.imageSize,
    required this.dotRadius,
    required this.transform,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final displayRect = _displayRect(size);

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final point in points) {
      final unzoomedPos = _pixelToDisplay(point, displayRect);
      final screenPos = MatrixUtils.transformPoint(transform, unzoomedPos);
      canvas.drawCircle(screenPos, dotRadius, ringPaint);
    }
  }

  Rect _displayRect(Size widgetSize) {
    final wRatio = widgetSize.width / widgetSize.height;
    final iRatio = imageSize.width / imageSize.height;
    double dW, dH;
    if (iRatio > wRatio) {
      dW = widgetSize.width;
      dH = dW / iRatio;
    } else {
      dH = widgetSize.height;
      dW = dH * iRatio;
    }
    return Rect.fromLTWH(
      (widgetSize.width - dW) / 2,
      (widgetSize.height - dH) / 2,
      dW,
      dH,
    );
  }

  Offset _pixelToDisplay(Point point, Rect displayRect) {
    final relX = point.x / imageSize.width;
    final relY = point.y / imageSize.height;
    return Offset(
      displayRect.left + relX * displayRect.width,
      displayRect.top + relY * displayRect.height,
    );
  }

  @override
  bool shouldRepaint(CountCanvasPainter old) => true;
}
