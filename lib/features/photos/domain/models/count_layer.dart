import 'point.dart';

class CountLayer {
  final String id;
  final String name;
  final int color;
  final List<Point> points;

  const CountLayer({
    required this.id,
    required this.name,
    required this.color,
    required this.points,
  });

  int get count => points.length;

  CountLayer copyWith({
    String? id,
    String? name,
    int? color,
    List<Point>? points,
  }) =>
      CountLayer(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        points: points ?? this.points,
      );
}
