import 'package:go_router/go_router.dart';
import '../../features/counting/presentation/counting_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/count/:photoId',
      builder: (context, state) {
        final photoId = state.pathParameters['photoId']!;
        return CountingScreen(photoId: photoId);
      },
    ),
  ],
);
