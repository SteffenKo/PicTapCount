import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../photos/domain/models/point.dart';

class CountCanvasPainter extends CustomPainter {
  final List<Point> points;
  final ui.Size imageSize;

  CountCanvasPainter({required this.points, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final displayRect = _displayRect(size);

    final fillPaint = Paint()
      ..color = const Color(0xFFFFA500).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final point in points) {
      final pos = _pixelToDisplay(point, displayRect);
      canvas.drawCircle(pos, 5.5, fillPaint);
      canvas.drawCircle(pos, 5.5, borderPaint);
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
  bool shouldRepaint(CountCanvasPainter old) =>
      old.points != points || old.imageSize != imageSize;
}
