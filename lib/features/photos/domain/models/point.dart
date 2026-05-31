class Point {
  final double x;
  final double y;

  const Point({required this.x, required this.y});

  Point copyWith({double? x, double? y}) =>
      Point(x: x ?? this.x, y: y ?? this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
