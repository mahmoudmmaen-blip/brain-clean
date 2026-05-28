import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/cognitive_tests/presentation/cognitive_hub_screen.dart';
import '../../features/cognitive_tests/presentation/memory_mini_game_screen.dart';
import '../../features/cognitive_tests/presentation/visual_cognitive_test_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/detox/presentation/detox_protocol_screen.dart';
import '../../features/diagnostic/presentation/diagnostic_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/recovery/presentation/recovery_grid_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../constants/app_routes.dart';

part 'app_router.g.dart';

/// App shell — splash hydrates Hive first, then home or in-progress diagnostic.
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.diagnostic,
        name: 'diagnostic',
        builder: (context, state) => const DiagnosticScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.detox,
        name: 'detox',
        builder: (context, state) => const DetoxProtocolScreen(),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        name: 'recovery',
        builder: (context, state) => const RecoveryGridScreen(),
      ),
      GoRoute(
        path: AppRoutes.cognitiveHub,
        name: 'cognitiveHub',
        builder: (context, state) => const CognitiveHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.cognitiveVisual,
        name: 'cognitiveVisual',
        builder: (context, state) => const VisualCognitiveTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.cognitiveMemory,
        name: 'cognitiveMemory',
        builder: (context, state) => const MemoryMiniGameScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
