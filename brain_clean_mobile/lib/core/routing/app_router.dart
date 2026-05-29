import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/cognitive_tests/presentation/cognitive_hub_screen.dart';
import '../../features/cognitive_tests/presentation/memory_mini_game_screen.dart';
import '../../features/cognitive_tests/presentation/visual_cognitive_test_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/detox/presentation/detox_protocol_screen.dart';
import '../../features/diagnostic/presentation/diagnostic_screen.dart';
import '../../features/diagnostic/presentation/visual_cognitive_test_screen.dart'
    as diagnostic_visual;
import '../../features/emotions/presentation/emotion_wheel_screen.dart';
import '../../features/focus/breathing_friction_screen.dart';
import '../../features/focus/delayed_gratification_screen.dart';
import '../../features/focus/silence_challenge_screen.dart';
import '../../features/focus/single_task_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/recovery/presentation/recovery_grid_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../constants/app_routes.dart';
import 'app_navigator_key.dart';

part 'app_router.g.dart';

/// Typed route for the visual cognitive odd-one-out test.
class VisualCognitiveTestRoute {
  const VisualCognitiveTestRoute();

  static const name = 'cognitiveTest';
  static const path = AppRoutes.cognitiveTest;

  static String get location => AppRoutes.cognitiveTest;
}

/// Typed route for the emotion feelings wheel.
class EmotionWheelRoute {
  const EmotionWheelRoute();

  static const name = 'emotionWheel';
  static const path = AppRoutes.emotionWheel;

  static String get location => AppRoutes.emotionWheel;
}

/// Typed route for silence challenge with path param [streakDays].
class SilenceChallengeRoute {
  const SilenceChallengeRoute({required this.streakDays});

  final int streakDays;

  static const name = 'silenceChallenge';
  static const path = '/silence-challenge/:streakDays';

  static String location(int streakDays) => '/silence-challenge/$streakDays';
}

/// Typed route for single-tasking focus mode.
class SingleTaskRoute {
  const SingleTaskRoute();

  static const name = 'singleTask';
  static const path = AppRoutes.singleTask;

  static String get location => AppRoutes.singleTask;
}

/// Typed route for delayed gratification timer.
class DelayedGratificationRoute {
  const DelayedGratificationRoute();

  static const name = 'delayedGratification';
  static const path = AppRoutes.delayedGratification;

  static String get location => AppRoutes.delayedGratification;
}

/// Typed route for breathing friction with path param [currentBhi].
class BreathingFrictionRoute {
  const BreathingFrictionRoute({required this.currentBhi});

  final int currentBhi;

  static const name = 'breathingFriction';
  static const path = '/breathing-friction/:currentBhi';

  static String location(int currentBhi) => '/breathing-friction/$currentBhi';
}

/// App shell — splash hydrates Hive, then routes to home or **live session** resume.
///
/// Live session routing ([AppRoutes.diagnostic]): when Hive holds draft metrics or
/// questionnaire state without a committed BC_score, [SplashScreen] opens
/// [DiagnosticScreen], which reads [diagnosticLiveSessionProvider] (not a stale
/// in-memory draft). Committed sessions land on [HomeScreen] / dashboard.
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    navigatorKey: appNavigatorKey,
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
      /// Live diagnostic session entry — questionnaire → results → BHI sliders.
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
      GoRoute(
        path: VisualCognitiveTestRoute.path,
        name: VisualCognitiveTestRoute.name,
        builder: (context, state) =>
            const diagnostic_visual.VisualCognitiveTestScreen(),
      ),
      GoRoute(
        path: EmotionWheelRoute.path,
        name: EmotionWheelRoute.name,
        builder: (context, state) => const EmotionWheelScreen(),
      ),
      GoRoute(
        path: SilenceChallengeRoute.path,
        name: SilenceChallengeRoute.name,
        builder: (context, state) {
          final daysParam = state.pathParameters['streakDays'];
          final streakDays = int.tryParse(daysParam ?? '') ?? 0;
          return SilenceChallengeScreen(streakDays: streakDays);
        },
      ),
      GoRoute(
        path: SingleTaskRoute.path,
        name: SingleTaskRoute.name,
        builder: (context, state) => const SingleTaskScreen(),
      ),
      GoRoute(
        path: DelayedGratificationRoute.path,
        name: DelayedGratificationRoute.name,
        builder: (context, state) => const DelayedGratificationScreen(),
      ),
      GoRoute(
        path: BreathingFrictionRoute.path,
        name: BreathingFrictionRoute.name,
        builder: (context, state) {
          final bhiParam = state.pathParameters['currentBhi'];
          final bhi = int.tryParse(bhiParam ?? '') ?? 50;
          return BreathingFrictionScreen(currentBhi: bhi);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
