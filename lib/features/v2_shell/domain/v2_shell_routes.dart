import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../daily_session/ui/today_home_screen.dart';
import '../../profile/ui/v2_profile_home_screen.dart';
import '../../progress/ui/progress_home_screen.dart';
import '../../recovery_plan/ui/plan_reveal_screen.dart';
import '../../v2_premium/ui/premium_overview_screen.dart';
import '../ui/v2_exercises_library_screen.dart';
import '../ui/v2_navigation_shell.dart';
import 'v2_shell_tab.dart';

/// Builds the production five-tab StatefulShellRoute for V2 (Pro mock).
///
/// Contextual routes (Plan reveal, Brain Check, Reports, Premium sub-flows)
/// remain outside this bar.
StatefulShellRoute buildV2NavigationShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return V2NavigationShell(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.today,
            name: 'v2Home',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: TodayHomeScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.exercises,
            name: 'v2Exercises',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: V2ExercisesLibraryScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.progress,
            name: 'v2Progress',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: ProgressHomeScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.pro,
            name: 'v2ProTab',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: PremiumOverviewScreen(
                source: 'shell',
                embeddedInShell: true,
              ),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.profile,
            name: 'v2Profile',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: V2ProfileHomeScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Contextual plan reveal — no longer a primary tab.
GoRoute buildV2PlanRevealRoute() {
  return GoRoute(
    path: V2ShellPaths.plan,
    name: 'v2PlanReveal',
    builder: (context, state) {
      final planId = state.uri.queryParameters['plan'];
      return PlanRevealScreen(planId: planId);
    },
  );
}
