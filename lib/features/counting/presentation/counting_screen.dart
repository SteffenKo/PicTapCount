import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/image_storage.dart';

import '../../../core/l10n/app_localizations.dart';
import '../application/counting_notifier.dart';
import '../application/counting_state.dart';
import 'widgets/count_canvas.dart';
import 'widgets/count_controls.dart';

class CountingScreen extends ConsumerStatefulWidget {
  final String photoId;

  const CountingScreen({required this.photoId, super.key});

  @override
  ConsumerState<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends ConsumerState<CountingScreen> {
  final _transformController = TransformationController();
  Size? _widgetSize;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, CountingState countingState) {
    final imageSize = countingState.imageSize;
    final widgetSize = _widgetSize;
    if (imageSize == null || widgetSize == null) return;

    final pixel = _tapToImagePixel(localPosition, widgetSize, imageSize);
    if (pixel == null) return;

    ref.read(countingNotifierProvider(widget.photoId).notifier).addPoint(pixel);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(countingNotifierProvider(widget.photoId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          asyncState.valueOrNull?.photo.title ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: asyncState.when(
        data: _buildBody,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(CountingState countingState) {
    final photo = countingState.photo;
    final imageSize = countingState.imageSize;
    final points = photo.activeLayer.points;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            _widgetSize = Size(constraints.maxWidth, constraints.maxHeight);
            return InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.5,
              maxScale: 8.0,
              child: GestureDetector(
                onTapUp: (d) => _handleTap(d.localPosition, countingState),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CustomPaint(
                    foregroundPainter: imageSize != null
                        ? CountCanvasPainter(
                            points: points,
                            imageSize: imageSize,
                          )
                        : null,
                    child: Image(
                      image: imageProvider(photo),
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _CountBadge(count: photo.totalCount),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CountControls(
            canUndo: points.isNotEmpty,
            canReset: points.isNotEmpty,
            onUndo: () =>
                ref.read(countingNotifierProvider(widget.photoId).notifier).undo(),
            onReset: () => _confirmReset(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.resetConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(countingNotifierProvider(widget.photoId).notifier).reset();
    }
  }

  Offset? _tapToImagePixel(Offset tap, Size widgetSize, ui.Size imageSize) {
    final rect = _displayRect(widgetSize, imageSize);
    if (!rect.contains(tap)) return null;
    final relX = (tap.dx - rect.left) / rect.width;
    final relY = (tap.dy - rect.top) / rect.height;
    return Offset(relX * imageSize.width, relY * imageSize.height);
  }

  Rect _displayRect(Size widgetSize, ui.Size imageSize) {
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
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA500),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
