import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Provides the GoRouter instance
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const Placeholder(), // TODO: Replace with Auth or Home screen
    ),
  ],
);
