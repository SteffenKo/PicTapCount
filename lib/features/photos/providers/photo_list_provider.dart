import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/photo.dart';
import 'repository_providers.dart';

final photoListProvider = FutureProvider<List<Photo>>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.getAll();
});
