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
  double _dotSize = 5.0;

  bool _editingTitle = false;
  TextEditingController? _titleController;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() => setState(() {});

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _titleController?.dispose();
    super.dispose();
  }

  void _startEditingTitle(String currentTitle) {
    _titleController = TextEditingController(text: currentTitle);
    setState(() => _editingTitle = true);
  }

  void _submitTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isNotEmpty) {
      ref.read(countingNotifierProvider(widget.photoId).notifier).rename(trimmed);
    }
    _titleController?.dispose();
    _titleController = null;
    setState(() => _editingTitle = false);
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
    final currentTitle = asyncState.valueOrNull?.photo.title ?? '';

    return Scaffold(
      appBar: AppBar(
        title: _editingTitle
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: _submitTitle,
              )
            : GestureDetector(
                onTap: () => _startEditingTitle(currentTitle),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        currentTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit_outlined, size: 14),
                  ],
                ),
              ),
        actions: _editingTitle
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _submitTitle(_titleController!.text),
                ),
              ]
            : null,
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
                  child: Image(
                    image: imageProvider(photo),
                    fit: BoxFit.contain,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                ),
              ),
            );
          },
        ),
        // Dots overlay outside InteractiveViewer so they don't scale with zoom.
        // The transform is applied manually so dots track their image positions.
        if (imageSize != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: CountCanvasPainter(
                  points: points,
                  imageSize: imageSize,
                  dotRadius: _dotSize,
                  transform: _transformController.value,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
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
            dotSize: _dotSize,
            onDotSizeChanged: (v) => setState(() => _dotSize = v),
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onTertiaryContainer,
            ),
      ),
    );
  }
}
