import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/application/app_preferences_provider.dart';
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
import '../../features/focus/focused_thinking_screen.dart';
import '../../features/focus/single_task_screen.dart';
import '../../features/games/crossword/crossword_screen.dart';
import '../../features/games/games_hub_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pomodoro/pomodoro_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pro/pro_paywall_screen.dart';
import '../../features/recovery/presentation/recovery_grid_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/weekly_report_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/brain_profile/ui/brain_check_building_screen.dart';
import '../../features/brain_profile/ui/profile_ready_boundary_screen.dart';
import '../../features/recovery_plan/ui/plan_building_screen.dart';
import '../../features/recovery_plan/ui/plan_today_preview_screen.dart';
import '../../features/recovery_plan/ui/plan_today_ready_boundary_screen.dart';
import '../../features/daily_session/ui/session_prepare_screen.dart';
import '../../features/daily_session/ui/session_act_screen.dart';
import '../../features/daily_session/ui/session_reflect_screen.dart';
import '../../features/daily_session/ui/session_leave_screen.dart';
import '../../features/weekly_review/ui/weekly_review_questions_screen.dart';
import '../../features/weekly_review/ui/weekly_review_summary_screen.dart';
import '../../features/brain_check/ui/brain_check_complete_boundary_screen.dart';
import '../../features/brain_check/ui/brain_check_flow_screen.dart';
import '../../features/v2_onboarding/ui/brain_check_entry_boundary_screen.dart';
import '../../features/v2_onboarding/ui/brain_check_ready_boundary_screen.dart';
import '../../features/v2_onboarding/ui/v2_onboarding_flow_screen.dart';
import '../../features/v2_reports/ui/measurement_history_screen.dart';
import '../../features/v2_reports/ui/reports_overview_screen.dart';
import '../../features/v2_reports/ui/weekly_artifact_detail_screen.dart';
import '../../features/v2_shell/domain/v2_shell_routes.dart';
import '../../features/v2_shell/domain/v2_shell_tab.dart';
import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../security/biometric_lock_screen.dart';
import '../security/security_status_provider.dart';
import '../v2/v2_feature_boundary.dart';
import 'app_navigator_key.dart';

// 🌟 [NEW] إضافة مسار شاشة واحة المشاعر
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
      if (location == AppRoutes.splash) return null;
      // V2 surfaces stay behind local feature boundary; V1 remains default.
      if (location.startsWith('/v2/') &&
          !V2FeatureBoundary.enableBrainProfileRoutes) {
        return AppRoutes.home;
      }
      // Unknown V2 paths recover to Home tab (when shell enabled).
      if (location.startsWith('/v2/') &&
          V2FeatureBoundary.enableV2Shell &&
          !V2ShellPaths.isKnownV2Location(location)) {
        return AppRoutes.v2Home;
      }
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
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.proPaywall,
        name: ProPaywallRoute.name,
        builder: (context, state) => const ProPaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: SettingsRoute.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: ProfileRoute.name,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.weeklyReport,
        name: WeeklyReportRoute.name,
        builder: (context, state) => const WeeklyReportScreen(),
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
        path: PomodoroRoute.path,
        name: PomodoroRoute.name,
        builder: (context, state) => const PomodoroScreen(),
      ),
      GoRoute(
        path: GamesHubRoute.path,
        name: GamesHubRoute.name,
        builder: (context, state) => const GamesHubScreen(),
      ),
      GoRoute(
        path: FocusedThinkingRoute.path,
        name: FocusedThinkingRoute.name,
        builder: (context, state) => const FocusedThinkingScreen(),
      ),
      GoRoute(
        path: CrosswordRoute.path,
        name: CrosswordRoute.name,
        builder: (context, state) => const CrosswordScreen(),
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
      
      // 🌟 [NEW] مسار واحة المشاعر
      GoRoute(
        path: '/emotion-oasis',
        name: 'emotionOasis',
        builder: (context, state) => const EmotionOasisScreen(),
      ),

      // V2 flows outside the shell + Slice 9.1 six-tab shell
      GoRoute(
        path: AppRoutes.v2BrainCheckBuilding,
        name: 'v2BrainCheckBuilding',
        builder: (context, state) => const BrainCheckBuildingScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2BrainProfile,
        name: 'v2BrainProfile',
        redirect: (context, state) {
          final session = state.uri.queryParameters['session'];
          if (session != null && session.isNotEmpty) {
            return '${AppRoutes.v2Profile}?session=${Uri.encodeComponent(session)}';
          }
          return AppRoutes.v2Profile;
        },
      ),
      GoRoute(
        path: AppRoutes.v2ProfileReadyBoundary,
        name: 'v2ProfileReadyBoundary',
        builder: (context, state) => const ProfileReadyBoundaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2PlanBuilding,
        name: 'v2PlanBuilding',
        builder: (context, state) => const PlanBuildingScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2PlanTodayPreview,
        name: 'v2PlanTodayPreview',
        builder: (context, state) {
          final planId = state.uri.queryParameters['plan'];
          return PlanTodayPreviewScreen(planId: planId);
        },
      ),
      GoRoute(
        path: AppRoutes.v2PlanTodayReady,
        name: 'v2PlanTodayReady',
        builder: (context, state) {
          final planId = state.uri.queryParameters['plan'];
          return PlanTodayReadyBoundaryScreen(planId: planId);
        },
      ),
      GoRoute(
        path: '/v2/today',
        name: 'v2TodayAlias',
        redirect: (context, state) => AppRoutes.v2Home,
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckEntry,
        name: 'v2BrainCheckEntry',
        redirect: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final source = state.uri.queryParameters['source'];
          final q = <String>[];
          if (mode != null && mode.isNotEmpty) {
            q.add('mode=${Uri.encodeComponent(mode)}');
          }
          if (source != null && source.isNotEmpty) {
            q.add('source=${Uri.encodeComponent(source)}');
          }
          if (q.isEmpty) return AppRoutes.v2Check;
          return '${AppRoutes.v2Check}?${q.join('&')}';
        },
      ),
      // Canonical four-tab shell: Today · Plan · Progress · Profile
      buildV2NavigationShellRoute(),
      // Contextual Brain Check (not a primary tab)
      GoRoute(
        path: AppRoutes.v2Check,
        name: 'v2Check',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'lite';
          final source = state.uri.queryParameters['source'] ?? 'shell';
          return BrainCheckEntryBoundaryScreen(mode: mode, source: source);
        },
      ),
      // Contextual Reports proof surface (not a primary tab)
      GoRoute(
        path: AppRoutes.v2Reports,
        name: 'v2Reports',
        builder: (context, state) => const ReportsOverviewScreen(),
        routes: [
          GoRoute(
            path: 'artifact',
            name: 'v2ReportArtifact',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'];
              return WeeklyArtifactDetailScreen(artifactId: id);
            },
          ),
          GoRoute(
            path: 'measurements',
            name: 'v2ReportMeasurements',
            builder: (context, state) => const MeasurementHistoryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.v2SessionPrepare,
        name: 'v2SessionPrepare',
        builder: (context, state) {
          final session = state.uri.queryParameters['session'];
          return SessionPrepareScreen(sessionId: session);
        },
      ),
      GoRoute(
        path: AppRoutes.v2SessionAct,
        name: 'v2SessionAct',
        builder: (context, state) {
          final session = state.uri.queryParameters['session'];
          return SessionActScreen(sessionId: session);
        },
      ),
      GoRoute(
        path: AppRoutes.v2SessionReflect,
        name: 'v2SessionReflect',
        builder: (context, state) {
          final session = state.uri.queryParameters['session'];
          return SessionReflectScreen(sessionId: session);
        },
      ),
      GoRoute(
        path: AppRoutes.v2SessionLeave,
        name: 'v2SessionLeave',
        builder: (context, state) {
          final session = state.uri.queryParameters['session'];
          final done = state.uri.queryParameters['done'] != '0';
          return SessionLeaveScreen(sessionId: session, done: done);
        },
      ),
      GoRoute(
        path: AppRoutes.v2WeeklyReview,
        name: 'v2WeeklyReview',
        builder: (context, state) => const WeeklyReviewQuestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2WeeklyReviewSummary,
        name: 'v2WeeklyReviewSummary',
        builder: (context, state) => const WeeklyReviewSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2Onboarding,
        name: 'v2Onboarding',
        builder: (context, state) => const V2OnboardingFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckFlow,
        name: 'v2BrainCheckFlow',
        builder: (context, state) => const BrainCheckFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckReadyBoundary,
        name: 'v2BrainCheckReadyBoundary',
        builder: (context, state) => const BrainCheckReadyBoundaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckCompleteBoundary,
        name: 'v2BrainCheckCompleteBoundary',
        builder: (context, state) => const BrainCheckCompleteBoundaryScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      final path = state.uri.path;
      final loc = AppLocalizations.of(context);
      if (path.startsWith('/v2/') && V2FeatureBoundary.enableV2Shell) {
        return Scaffold(
          body: Center(
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => GoRouter.of(context).go(AppRoutes.v2Home),
                child: Text(loc?.v2NavRecoverHome ?? 'Home'),
              ),
            ),
          ),
        );
      }
      return Scaffold(
        body: Center(
          child: Text(loc?.v2NavRouteNotFound ?? 'Route not found'),
        ),
      );
    },
  );
}