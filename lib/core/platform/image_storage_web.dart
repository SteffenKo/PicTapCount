import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/photos/domain/models/photo.dart';

Box<dynamic> get _box => Hive.box<dynamic>('imageBytes');

Future<String> saveImage(XFile picked, String photoId) async {
  final bytes = await picked.readAsBytes();
  await _box.put(photoId, bytes);
  return photoId;
}

Future<void> deleteImage(String imagePath) async {
  await _box.delete(imagePath);
}

ImageProvider imageProvider(Photo photo) {
  final dynamic raw = _box.get(photo.imagePath);
  if (raw == null) return MemoryImage(Uint8List(0));
  final bytes = raw is Uint8List ? raw : Uint8List.fromList((raw as List).cast<int>());
  return MemoryImage(bytes);
}
