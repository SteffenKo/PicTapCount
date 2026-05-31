import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/photos/data/hive/hive_adapters.dart';
import 'features/photos/domain/models/photo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PointAdapter());
  Hive.registerAdapter(CountLayerAdapter());
  Hive.registerAdapter(PhotoAdapter());
  await Hive.openBox<Photo>('photos');
  runApp(const ProviderScope(child: App()));
}
