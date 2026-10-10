import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_navigator_key.dart';
import '../../core/security/biometric_lock_screen.dart';
import '../../core/security/security_status_provider.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../application/clarity_check_session_provider.dart';
import '../application/v3_onboarding_gate_provider.dart';
import '../ui/onboarding/clarity_check_screen.dart';
import '../ui/onboarding/result_plan_screen.dart';
import '../ui/onboarding/setup_screen.dart';
import '../ui/onboarding/welcome_screen.dart';
import '../ui/paywall/v3_paywall_screen.dart';
import '../ui/placeholders/v3_simple_placeholder.dart';
import '../ui/session/session_player_screen.dart';
import '../ui/shell/v3_main_shell.dart';
import '../ui/shell/v3_tab_placeholder.dart';
import '../ui/today/today_screen.dart';
import 'v3_routes.dart';
import 'v3_startup.dart';

class V3RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

final v3RouterRefreshProvider = Provider<V3RouterRefresh>((ref) {
  final notifier = V3RouterRefresh();
  ref.onDispose(notifier.dispose);
  ref.listen(v3OnboardingGateProvider, (_, __) => notifier.notify());
  ref.listen(biometricLockSettingsProvider, (_, __) => notifier.notify());
  ref.listen(biometricSessionProvider, (_, __) => notifier.notify());
  return notifier;
});

final v3GoRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(v3RouterRefreshProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: V3Routes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == V3Routes.splash) return null;

      final gate = ref.read(v3OnboardingGateProvider);
      if (gate == null) return null;

      final onboardingDone = gate;
      if (!onboardingDone) {
        if (!V3Routes.isOnboardingPath(path) &&
            path != V3Routes.biometricLock) {
          return V3Routes.welcome;
        }
        return null;
      }

      if (path == V3Routes.welcome || path == V3Routes.setup) {
        return V3Routes.today;
      }

      final biometricEnabled = ref.read(biometricLockSettingsProvider);
      final biometricUnlocked = ref.read(biometricSessionProvider);
      if (biometricEnabled &&
          !biometricUnlocked &&
          path != V3Routes.biometricLock &&
          !V3Routes.isOnboardingPath(path)) {
        return V3Routes.biometricLock;
      }
      if (biometricUnlocked && path == V3Routes.biometricLock) {
        return V3Startup.afterBiometricUnlock(onboardingDone: onboardingDone);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: V3Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: V3Routes.biometricLock,
        builder: (context, state) => const BiometricLockScreen(),
      ),
      GoRoute(
        path: V3Routes.welcome,
        builder: (context, state) => const V3WelcomeScreen(),
      ),
      GoRoute(
        path: V3Routes.check,
        builder: (context, state) {
          final modeRaw = state.uri.queryParameters['mode'] ?? 'baseline';
          final mode = modeRaw == 'recheck'
              ? ClarityCheckMode.recheck
              : ClarityCheckMode.baseline;
          final returnTo = state.uri.queryParameters['returnTo'];
          final dayRaw = state.uri.queryParameters['day'];
          final day = dayRaw == null ? null : int.tryParse(dayRaw);
          return V3ClarityCheckScreen(
            mode: mode,
            returnTo: returnTo,
            programDay: day,
          );
        },
      ),
      GoRoute(
        path: V3Routes.setup,
        builder: (context, state) => const V3SetupScreen(),
      ),
      GoRoute(
        path: V3Routes.result,
        builder: (context, state) => const V3ResultPlanScreen(),
      ),
      GoRoute(
        path: V3Routes.session,
        builder: (context, state) {
          final day = int.tryParse(state.pathParameters['n'] ?? '1') ?? 1;
          return V3SessionPlayerScreen(day: day);
        },
      ),
      GoRoute(
        path: V3Routes.paywall,
        builder: (context, state) => V3PaywallScreen(
          source: state.uri.queryParameters['source'],
        ),
      ),
      GoRoute(
        path: V3Routes.sos,
        builder: (context, state) => const V3SimplePlaceholder(
          title: 'SOS',
          routeKey: Key('v3_sos'),
        ),
      ),
      GoRoute(
        path: V3Routes.graduation,
        builder: (context, state) => const V3SimplePlaceholder(
          title: 'Graduation',
          routeKey: Key('v3_graduation'),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return V3MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: V3Routes.today,
                builder: (context, state) => const V3TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: V3Routes.program,
                builder: (context, state) => const V3TabPlaceholder(
                  tabKey: V3ShellKeys.programTab,
                  title: 'Program',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: V3Routes.tools,
                builder: (context, state) => const V3TabPlaceholder(
                  tabKey: V3ShellKeys.toolsTab,
                  title: 'Tools',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: V3Routes.progress,
                builder: (context, state) => const V3TabPlaceholder(
                  tabKey: V3ShellKeys.progressTab,
                  title: 'Progress',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: V3Routes.settings,
        builder: (context, state) => const V3SimplePlaceholder(
          title: 'Settings',
          routeKey: Key('v3_settings'),
        ),
      ),
    ],
  );
});
