import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/photo.dart';
import '../domain/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final Box<Photo> _box;

  PhotoRepositoryImpl(this._box);

  @override
  Future<List<Photo>> getAll() async {
    final photos = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  @override
  Future<Photo?> getById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> save(Photo photo) async {
    await _box.put(photo.id, photo);
  }

  @override
  Future<void> delete(String id) async {
    final photo = _box.get(id);
    if (photo != null) {
      try {
        final file = File(photo.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    await _box.delete(id);
  }
}
