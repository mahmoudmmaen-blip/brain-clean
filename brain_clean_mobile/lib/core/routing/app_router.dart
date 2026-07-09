import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/presentation/app_shell.dart';
import '../../features/anxiety/presentation/anxiety_diagnostic_screen.dart';
import '../../features/anxiety/presentation/anxiety_result_screen.dart';
import '../../features/worry/presentation/worry_journal_screen.dart';
import '../../features/worry/presentation/worry_window_screen.dart';
import '../../features/accountability/accountability_screen.dart';
import '../../features/cognitive_tests/presentation/cognitive_hub_screen.dart';
import '../../features/cognitive_tests/presentation/memory_mini_game_screen.dart';
import '../../features/cognitive_tests/presentation/visual_cognitive_test_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/detox/presentation/detox_protocol_screen.dart';
import '../../features/diagnostic/presentation/diagnostic_screen.dart';
import '../../features/diagnostic/presentation/visual_cognitive_test_screen.dart'
    as diagnostic_visual;
import '../../features/emotions/presentation/emotion_wheel_screen.dart';
import '../../features/exercises/presentation/exercises_tab_screen.dart';
import '../../features/focus/breathing_friction_screen.dart';
import '../../features/focus/delayed_gratification_screen.dart';
import '../../features/focus/silence_challenge_screen.dart';
import '../../features/focus/focused_thinking_screen.dart';
import '../../features/focus/single_task_screen.dart';
import '../../features/games/crossword/crossword_screen.dart';
import '../../features/games/games_hub_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/journey/presentation/journey_tab_screen.dart';
import '../../features/more/presentation/more_tab_screen.dart';
import '../../features/pomodoro/pomodoro_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pro/pro_paywall_screen.dart';
import '../../features/recovery/presentation/recovery_grid_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/weekly_report_screen.dart';
import '../../features/safa_tab/presentation/safa_tab_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../constants/app_routes.dart';
import '../security/biometric_lock_screen.dart';
import '../storage/hive_bootstrap.dart';
import '../security/security_status_provider.dart';
import 'app_navigator_key.dart';

import '../../features/pro_modules/presentation/screens/emotion_oasis_screen.dart';

part 'app_router.g.dart';

/// Typed route for Brain Rot quiz (diagnostic questionnaire).
class BrainRotQuizRoute {
  const BrainRotQuizRoute();

  static const name = 'brainRotQuiz';
  static const path = AppRoutes.diagnostic;

  static String get location => AppRoutes.diagnostic;
}

/// Typed route for onboarding.
class OnboardingRoute {
  const OnboardingRoute();

  static const name = 'onboarding';
  static const path = AppRoutes.onboarding;

  static String get location => AppRoutes.onboarding;
}

/// Typed route for Pro paywall.
class ProPaywallRoute {
  const ProPaywallRoute();

  static const name = 'proPaywall';
  static const path = AppRoutes.proPaywall;

  static String get location => AppRoutes.proPaywall;
}

/// Typed route for settings.
class SettingsRoute {
  const SettingsRoute();

  static const name = 'settings';
  static const path = AppRoutes.settings;

  static String get location => AppRoutes.settings;
}

/// Typed route for user profile.
class ProfileRoute {
  const ProfileRoute();

  static const name = 'profile';
  static const path = AppRoutes.profile;

  static String get location => AppRoutes.profile;
}

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
  static const path = 'silence-challenge/:streakDays';

  static String location(int streakDays) =>
      AppRoutes.silenceChallenge(streakDays);
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
  static const path = 'breathing-friction/:currentBhi';

  static String location(int currentBhi) =>
      AppRoutes.breathingFriction(currentBhi);
}

/// Typed route for Pomodoro focus timer.
class PomodoroRoute {
  const PomodoroRoute();

  static const name = 'pomodoro';
  static const path = AppRoutes.pomodoro;

  static String get location => AppRoutes.pomodoro;
}

/// Typed route for focused thinking challenge.
class FocusedThinkingRoute {
  const FocusedThinkingRoute();

  static const name = 'focusedThinking';
  static const path = AppRoutes.focusedThinking;

  static String get location => AppRoutes.focusedThinking;
}

/// Typed route for Arabic crossword.
class CrosswordRoute {
  const CrosswordRoute();

  static const name = 'crossword';
  static const path = AppRoutes.crossword;

  static String get location => AppRoutes.crossword;
}

/// Typed route for brain games hub.
class GamesHubRoute {
  const GamesHubRoute();

  static const name = 'gamesHub';
  static const path = AppRoutes.games;

  static String get location => AppRoutes.games;
}

/// Typed route for weekly progress report.
class WeeklyReportRoute {
  const WeeklyReportRoute();

  static const name = 'weeklyReport';
  static const path = AppRoutes.weeklyReport;

  static String get location => AppRoutes.weeklyReport;
}

/// App shell — splash hydrates Hive, then routes to home or **live session** resume.
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final prefs = ref.watch(appPreferencesProvider);
  final biometricEnabled = ref.watch(biometricLockSettingsProvider);
  final biometricUnlocked = ref.watch(biometricSessionProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.uri.path;
      final legacy = AppRoutes.legacyRedirect(location);
      if (legacy != null) return legacy;

      if (HiveBootstrap.isRoutingGuardEnabled &&
          location != AppRoutes.splash &&
          !HiveBootstrap.isInitialized &&
          !HiveBootstrap.hasRegisteredAdapters) {
        return AppRoutes.splash;
      }
      if (location == AppRoutes.splash) return null;
      if (!prefs.hasSeenOnboarding && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      if (biometricEnabled &&
          !biometricUnlocked &&
          location != AppRoutes.biometricLock &&
          location != AppRoutes.onboarding) {
        return AppRoutes.biometricLock;
      }
      if (biometricUnlocked && location == AppRoutes.biometricLock) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometricLock,
        name: 'biometricLock',
        builder: (context, state) => const BiometricLockScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: OnboardingRoute.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.anxietyDiagnostic,
        name: 'anxietyDiagnostic',
        builder: (context, state) => const AnxietyDiagnosticScreen(),
      ),
      GoRoute(
        path: AppRoutes.anxietyResult,
        name: 'anxietyResult',
        builder: (context, state) => const AnxietyResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.worryJournal,
        name: 'worryJournal',
        builder: (context, state) => const WorryJournalScreen(),
      ),
      GoRoute(
        path: AppRoutes.worryWindow,
        name: 'worryWindow',
        builder: (context, state) => const WorryWindowScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'diagnostic',
                    name: 'diagnostic',
                    builder: (context, state) => const DiagnosticScreen(),
                  ),
                  GoRoute(
                    path: 'detox',
                    name: 'detox',
                    builder: (context, state) => const DetoxProtocolScreen(),
                  ),
                  GoRoute(
                    path: 'recovery',
                    name: 'recovery',
                    builder: (context, state) => const RecoveryGridScreen(),
                  ),
                  GoRoute(
                    path: 'pomodoro',
                    name: PomodoroRoute.name,
                    builder: (context, state) => const PomodoroScreen(),
                  ),
                  GoRoute(
                    path: 'single-task',
                    name: SingleTaskRoute.name,
                    builder: (context, state) => const SingleTaskScreen(),
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
                    path: BreathingFrictionRoute.path,
                    name: BreathingFrictionRoute.name,
                    builder: (context, state) {
                      final bhiParam = state.pathParameters['currentBhi'];
                      final bhi = int.tryParse(bhiParam ?? '') ?? 50;
                      return BreathingFrictionScreen(currentBhi: bhi);
                    },
                  ),
                  GoRoute(
                    path: 'emotion-wheel',
                    name: EmotionWheelRoute.name,
                    builder: (context, state) => const EmotionWheelScreen(),
                  ),
                  GoRoute(
                    path: 'delayed-gratification',
                    name: DelayedGratificationRoute.name,
                    builder: (context, state) =>
                        const DelayedGratificationScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.exercises,
                name: 'exercises',
                builder: (context, state) => const ExercisesTabScreen(),
                routes: [
                  GoRoute(
                    path: 'cognitive-hub',
                    name: 'cognitiveHub',
                    builder: (context, state) => const CognitiveHubScreen(),
                  ),
                  GoRoute(
                    path: 'cognitive-visual',
                    name: 'cognitiveVisual',
                    builder: (context, state) =>
                        const VisualCognitiveTestScreen(),
                  ),
                  GoRoute(
                    path: 'cognitive-memory',
                    name: 'cognitiveMemory',
                    builder: (context, state) => const MemoryMiniGameScreen(),
                  ),
                  GoRoute(
                    path: 'cognitive-test',
                    name: VisualCognitiveTestRoute.name,
                    builder: (context, state) =>
                        const diagnostic_visual.VisualCognitiveTestScreen(),
                  ),
                  GoRoute(
                    path: 'focused-thinking',
                    name: FocusedThinkingRoute.name,
                    builder: (context, state) =>
                        const FocusedThinkingScreen(),
                  ),
                  GoRoute(
                    path: 'crossword',
                    name: CrosswordRoute.name,
                    builder: (context, state) => const CrosswordScreen(),
                  ),
                  GoRoute(
                    path: 'games',
                    name: GamesHubRoute.name,
                    builder: (context, state) => const GamesHubScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.safa,
                name: 'safa',
                builder: (context, state) => const SafaTabScreen(),
                routes: [
                  GoRoute(
                    path: 'emotion-oasis',
                    name: 'emotionOasis',
                    builder: (context, state) => const EmotionOasisScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journey,
                name: 'journey',
                builder: (context, state) => const JourneyTabScreen(),
                routes: [
                  GoRoute(
                    path: 'dashboard',
                    name: 'dashboard',
                    builder: (context, state) => const DashboardScreen(),
                  ),
                  GoRoute(
                    path: 'weekly-report',
                    name: WeeklyReportRoute.name,
                    builder: (context, state) => const WeeklyReportScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                name: 'more',
                builder: (context, state) => const MoreTabScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: SettingsRoute.name,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    name: ProfileRoute.name,
                    builder: (context, state) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'pro-paywall',
                    name: ProPaywallRoute.name,
                    builder: (context, state) => const ProPaywallScreen(),
                  ),
                  GoRoute(
                    path: 'accountability',
                    name: 'accountability',
                    builder: (context, state) => const AccountabilityScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
