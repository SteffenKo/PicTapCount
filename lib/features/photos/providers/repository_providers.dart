import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/photo_repository_impl.dart';
import '../domain/models/photo.dart';
import '../domain/photo_repository.dart';

final photoBoxProvider = Provider<Box<Photo>>((ref) {
  return Hive.box<Photo>('photos');
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.watch(photoBoxProvider));
});
