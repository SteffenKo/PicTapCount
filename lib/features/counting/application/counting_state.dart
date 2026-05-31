import 'dart:ui';
import '../../photos/domain/models/photo.dart';

class CountingState {
  final Photo photo;
  final Size? imageSize;

  const CountingState({required this.photo, this.imageSize});

  CountingState copyWith({Photo? photo, Size? imageSize}) => CountingState(
        photo: photo ?? this.photo,
        imageSize: imageSize ?? this.imageSize,
      );
}
