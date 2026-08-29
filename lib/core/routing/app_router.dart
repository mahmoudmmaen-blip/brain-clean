import 'package:flutter/foundation.dart';
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
import '../../features/focus/delayed_gratification_screen.dart';
import '../../features/focus/silence_challenge_screen.dart';
import '../../features/focus/focused_thinking_screen.dart';
import '../../features/focus/single_task_screen.dart';
import '../../features/games/crossword/crossword_screen.dart';
import '../../features/games/games_hub_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pomodoro/pomodoro_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/recovery/presentation/recovery_grid_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/weekly_report_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/brain_profile/ui/brain_check_building_screen.dart';
import '../../features/brain_profile/ui/brain_profile_reveal_screen.dart';
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
import '../../features/interactive_diagnostic/ui/interactive_diagnostic_flow_screen.dart';
import '../../features/brain_rot_index/ui/bri_test_screen.dart';
import '../../features/quick_tests/ui/digital_brain_rot_test_screen.dart';
import '../../features/quick_tests/ui/iq_test_screen.dart';
import '../../features/quick_tests/ui/tests_catalog_screen.dart';
import '../../features/daily_program/domain/daily_program_activity_kind.dart';
import '../../features/daily_program/ui/daily_program_cognitive_gate_screen.dart';
import '../../features/daily_program/ui/daily_program_timeline_screen.dart';
import '../../features/daily_program/ui/daily_program_timer_screen.dart';
import '../../features/daily_program/ui/evening_review_screen.dart';
import '../../features/v2_reports/ui/measurement_history_screen.dart';
import '../../features/v2_reports/ui/reports_overview_screen.dart';
import '../../features/v2_reports/ui/weekly_artifact_detail_screen.dart';
import '../../features/v2_premium/ui/premium_overview_screen.dart';
import '../../features/v2_premium/ui/premium_plans_screen.dart';
import '../../features/v2_premium/ui/premium_status_screen.dart';
import '../../features/v2_premium/ui/premium_success_screen.dart';
import '../../features/v2_safa/domain/safa_session_origin.dart';
import '../../features/v2_safa/ui/safa_support_screen.dart';
import '../../features/v2_shell/domain/v2_shell_routes.dart';
import '../../features/v2_shell/domain/v2_shell_tab.dart';
import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../security/biometric_lock_screen.dart';
import '../security/security_status_provider.dart';
import '../v2/v2_feature_boundary.dart';
import 'app_navigator_key.dart';
import 'go_router_refresh_notifier.dart';
import 'startup_destination.dart';

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
@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final refresh = GoRouterRefreshNotifier();
  ref.onDispose(refresh.dispose);

  ref.listen(appPreferencesProvider, (_, __) => refresh.refresh());
  ref.listen(biometricLockSettingsProvider, (_, __) => refresh.refresh());
  ref.listen(biometricSessionProvider, (_, __) => refresh.refresh());

  return GoRouter(
    refreshListenable: refresh,
    navigatorKey: appNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.uri.path;
      final prefs = ref.read(appPreferencesProvider);
      if (kDebugMode && location != AppRoutes.splash) {
        debugPrint(
          '[RouterRedirect] path=$location '
          'hasSeenOnboarding=${prefs.hasSeenOnboarding}',
        );
      }
      if (location == AppRoutes.splash) return null;
      // V2 surfaces stay behind local feature boundary; V1 remains default.
      // Premium purchase/manage remains available in V1 mode (shared entitlement).
      if (location.startsWith('/v2/') &&
          !V2FeatureBoundary.enableBrainProfileRoutes) {
        if (location == AppRoutes.v2Premium ||
            location.startsWith('${AppRoutes.v2Premium}/')) {
          return null;
        }
        return AppRoutes.home;
      }
      // Unknown V2 paths recover to Home tab (when shell enabled).
      if (location.startsWith('/v2/') &&
          V2FeatureBoundary.enableV2Shell &&
          !V2ShellPaths.isKnownV2Location(location)) {
        return AppRoutes.v2Home;
      }
      // Safa deep link without origin context → HOM-01 (Contract §15.2).
      if (location == AppRoutes.v2Safa) {
        final origin = state.uri.queryParameters['origin'];
        if (origin == null || origin.trim().isEmpty) {
          return AppRoutes.v2Home;
        }
      }
      if (!prefs.hasSeenOnboarding) {
        final onboardingRedirect =
            StartupDestination.redirectIfOnboardingIncomplete(location);
        if (onboardingRedirect != null) {
          if (kDebugMode) {
            debugPrint(
              '[RouterRedirect] onboarding gate → $onboardingRedirect '
              '(hasSeenOnboarding=false)',
            );
          }
          return onboardingRedirect;
        }
      }
      final biometricEnabled = ref.read(biometricLockSettingsProvider);
      final biometricUnlocked = ref.read(biometricSessionProvider);
      if (biometricEnabled &&
          !biometricUnlocked &&
          location != AppRoutes.biometricLock &&
          !StartupDestination.isOnboardingLocation(location)) {
        return AppRoutes.biometricLock;
      }
      if (biometricUnlocked && location == AppRoutes.biometricLock) {
        return prefs.hasSeenOnboarding
            ? StartupDestination.resolve()
            : StartupDestination.onboarding();
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
        // Legacy V1 path — redirect to store-backed V2 Premium (honest offerings).
        redirect: (context, state) =>
            AppRoutes.v2PremiumWithSource('legacy_paywall'),
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
        builder: (context, state) {
          final session = state.uri.queryParameters['session'];
          return BrainProfileRevealScreen(sessionId: session);
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
      // Pro mock five-tab shell: Home · Exercises · Progress · Pro · Profile
      buildV2NavigationShellRoute(),
      buildV2PlanRevealRoute(),
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
      GoRoute(
        path: AppRoutes.v2InteractiveDiagnostic,
        name: 'v2InteractiveDiagnostic',
        builder: (context, state) => const InteractiveDiagnosticFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2Tests,
        name: 'v2Tests',
        builder: (context, state) => const TestsCatalogScreen(),
        routes: [
          GoRoute(
            path: 'iq',
            name: 'v2IqTest',
            builder: (context, state) => const IqTestScreen(),
          ),
          GoRoute(
            path: 'digital-brain-rot',
            name: 'v2DigitalBrainRotTest',
            builder: (context, state) => const DigitalBrainRotTestScreen(),
          ),
          GoRoute(
            path: 'bri',
            name: 'v2BriTest',
            builder: (context, state) => const BriTestScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.v2DailyProgram,
        name: 'v2DailyProgram',
        builder: (context, state) => const DailyProgramTimelineScreen(),
      ),
      GoRoute(
        path: AppRoutes.v2DailyProgramTimer,
        name: 'v2DailyProgramTimer',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final minutes = int.tryParse(q['minutes'] ?? '') ?? 15;
          final dayRaw = q['day'];
          DateTime? day;
          if (dayRaw != null && dayRaw.contains('-')) {
            final parts = dayRaw.split('-');
            if (parts.length == 3) {
              day = DateTime(
                int.tryParse(parts[0]) ?? DateTime.now().year,
                int.tryParse(parts[1]) ?? 1,
                int.tryParse(parts[2]) ?? 1,
              );
            }
          }
          return DailyProgramTimerScreen(
            activityId: q['activityId'] ?? 'activity',
            minutes: minutes,
            title: q['title'] ?? '',
            day: day,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.v2EveningReview,
        name: 'v2EveningReview',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final dayRaw = q['day'];
          DateTime? day;
          if (dayRaw != null && dayRaw.contains('-')) {
            final parts = dayRaw.split('-');
            if (parts.length == 3) {
              day = DateTime(
                int.tryParse(parts[0]) ?? DateTime.now().year,
                int.tryParse(parts[1]) ?? 1,
                int.tryParse(parts[2]) ?? 1,
              );
            }
          }
          return EveningReviewScreen(
            activityId: q['activityId'] ?? 'evening_review',
            day: day,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.v2DailyProgramCognitive,
        name: 'v2DailyProgramCognitive',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final kindRaw = (q['kind'] ?? 'stroop').toLowerCase();
          final kind = kindRaw == 'nback'
              ? DailyProgramActivityKind.cognitiveNBack
              : DailyProgramActivityKind.cognitiveStroop;
          final dayRaw = q['day'];
          DateTime? day;
          if (dayRaw != null && dayRaw.contains('-')) {
            final parts = dayRaw.split('-');
            if (parts.length == 3) {
              day = DateTime(
                int.tryParse(parts[0]) ?? DateTime.now().year,
                int.tryParse(parts[1]) ?? 1,
                int.tryParse(parts[2]) ?? 1,
              );
            }
          }
          return DailyProgramCognitiveGateScreen(
            activityId: q['activityId'] ?? 'cognitive',
            kind: kind,
            day: day,
          );
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
      // Contextual Safa (not a tab) — SAF-01
      GoRoute(
        path: AppRoutes.v2Safa,
        name: 'v2Safa',
        builder: (context, state) {
          final origin = SafaSessionOriginX.parse(
            state.uri.queryParameters['origin'],
          );
          final returnTo = state.uri.queryParameters['returnTo'];
          final view = state.uri.queryParameters['view'];
          return SafaSupportScreen(
            origin: origin,
            returnPath: returnTo,
            view: view,
          );
        },
      ),
      // Contextual Premium (not a tab) — PRE-01…PRE-03
      GoRoute(
        path: AppRoutes.v2Premium,
        name: 'v2Premium',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'];
          return PremiumOverviewScreen(source: source);
        },
        routes: [
          GoRoute(
            path: 'plans',
            name: 'v2PremiumPlans',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'];
              return PremiumPlansScreen(source: source);
            },
          ),
          GoRoute(
            path: 'success',
            name: 'v2PremiumSuccess',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'];
              return PremiumSuccessScreen(source: source);
            },
          ),
          GoRoute(
            path: 'status',
            name: 'v2PremiumStatus',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'];
              return PremiumStatusScreen(source: source);
            },
          ),
          GoRoute(
            path: 'restore',
            name: 'v2PremiumRestore',
            builder: (context, state) {
              final source = state.uri.queryParameters['source'] ?? 'restore';
              return PremiumStatusScreen(source: source, autoRestore: true);
            },
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
