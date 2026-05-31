import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/count_layer.dart';
import '../../domain/models/photo.dart';
import '../../domain/models/point.dart';

class PointAdapter extends TypeAdapter<Point> {
  @override
  final int typeId = 0;

  @override
  Point read(BinaryReader reader) {
    return Point(
      x: reader.readDouble(),
      y: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Point obj) {
    writer.writeDouble(obj.x);
    writer.writeDouble(obj.y);
  }
}

class CountLayerAdapter extends TypeAdapter<CountLayer> {
  @override
  final int typeId = 1;

  @override
  CountLayer read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final color = reader.readInt();
    final pointCount = reader.readInt();
    final points = <Point>[];
    for (var i = 0; i < pointCount; i++) {
      points.add(reader.read() as Point);
    }
    return CountLayer(id: id, name: name, color: color, points: points);
  }

  @override
  void write(BinaryWriter writer, CountLayer obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.color);
    writer.writeInt(obj.points.length);
    for (final point in obj.points) {
      writer.write(point);
    }
  }
}

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 2;

  @override
  Photo read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final imagePath = reader.readString();
    final createdAt =
        DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final layerCount = reader.readInt();
    final layers = <CountLayer>[];
    for (var i = 0; i < layerCount; i++) {
      layers.add(reader.read() as CountLayer);
    }
    return Photo(
      id: id,
      title: title,
      imagePath: imagePath,
      createdAt: createdAt,
      countLayers: layers,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.imagePath);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.countLayers.length);
    for (final layer in obj.countLayers) {
      writer.write(layer);
    }
  }
}
