import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/photos/domain/models/photo.dart';

Future<String> saveImage(XFile picked, String photoId) async {
  final appDir = await getApplicationDocumentsDirectory();
  final destPath = p.join(appDir.path, 'pictapcount', '$photoId.jpg');
  await Directory(p.dirname(destPath)).create(recursive: true);
  await File(picked.path).copy(destPath);
  return destPath;
}

Future<void> deleteImage(String imagePath) async {
  try {
    final file = File(imagePath);
    if (await file.exists()) await file.delete();
  } catch (_) {}
}

ImageProvider imageProvider(Photo photo) => FileImage(File(photo.imagePath));
