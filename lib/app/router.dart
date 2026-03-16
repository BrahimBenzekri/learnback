import 'package:go_router/go_router.dart';

import 'package:learnback/features/splash/presentation/screens/splash_screen.dart';

// Provides the GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
  ],
);
