import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/image_storage.dart';

import '../../photos/domain/models/count_layer.dart';
import '../../photos/domain/models/photo.dart';
import '../../photos/domain/models/point.dart';
import '../../photos/providers/photo_list_provider.dart';
import '../../photos/providers/repository_providers.dart';
import 'counting_state.dart';

class CountingNotifier extends FamilyAsyncNotifier<CountingState, String> {
  @override
  Future<CountingState> build(String arg) async {
    final repo = ref.read(photoRepositoryProvider);
    final photo = await repo.getById(arg);
    if (photo == null) throw Exception('Photo not found: $arg');
    final imageSize = await _resolveImageSize(photo);
    return CountingState(photo: photo, imageSize: imageSize);
  }

  void addPoint(ui.Offset imagePixel) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = _withUpdatedLayer(
      current,
      (layer) => layer.copyWith(
        points: [...layer.points, Point(x: imagePixel.dx, y: imagePixel.dy)],
      ),
    );
    state = AsyncData(updated);
    _autoSave(updated.photo);
  }

  void undo() {
    final current = state.valueOrNull;
    if (current == null) return;
    final points = current.photo.activeLayer.points;
    if (points.isEmpty) return;
    final updated = _withUpdatedLayer(
      current,
      (layer) => layer.copyWith(points: points.sublist(0, points.length - 1)),
    );
    state = AsyncData(updated);
    _autoSave(updated.photo);
  }

  void reset() {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = _withUpdatedLayer(
      current,
      (layer) => layer.copyWith(points: const []),
    );
    state = AsyncData(updated);
    _autoSave(updated.photo);
  }

  CountingState _withUpdatedLayer(
    CountingState current,
    CountLayer Function(CountLayer) updater,
  ) {
    final newLayer = updater(current.photo.activeLayer);
    final newLayers = [newLayer, ...current.photo.countLayers.skip(1)];
    return current.copyWith(photo: current.photo.copyWith(countLayers: newLayers));
  }

  void _autoSave(Photo photo) {
    ref.read(photoRepositoryProvider).save(photo).then((_) {
      ref.invalidate(photoListProvider);
    }).catchError((_) {});
  }

  Future<ui.Size> _resolveImageSize(Photo photo) async {
    final completer = Completer<ui.Size>();
    final provider = imageProvider(photo);
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.complete(ui.Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
        stream.removeListener(listener);
      },
      onError: (e, _) {
        completer.completeError('Failed to load image dimensions');
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}

final countingNotifierProvider =
    AsyncNotifierProvider.family<CountingNotifier, CountingState, String>(
  CountingNotifier.new,
);
