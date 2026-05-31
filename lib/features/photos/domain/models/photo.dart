import 'count_layer.dart';

class Photo {
  final String id;
  final String title;
  final String imagePath;
  final DateTime createdAt;
  final List<CountLayer> countLayers;

  const Photo({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.createdAt,
    required this.countLayers,
  });

  int get totalCount =>
      countLayers.fold(0, (sum, layer) => sum + layer.count);

  CountLayer get activeLayer => countLayers.first;

  Photo copyWith({
    String? id,
    String? title,
    String? imagePath,
    DateTime? createdAt,
    List<CountLayer>? countLayers,
  }) =>
      Photo(
        id: id ?? this.id,
        title: title ?? this.title,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
        countLayers: countLayers ?? this.countLayers,
      );
}
