import 'models/photo.dart';

abstract class PhotoRepository {
  Future<List<Photo>> getAll();
  Future<Photo?> getById(String id);
  Future<void> save(Photo photo);
  Future<void> delete(String id);
}
