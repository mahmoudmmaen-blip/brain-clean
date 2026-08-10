import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../daily_session/ui/today_home_screen.dart';
import '../../profile/ui/v2_profile_home_screen.dart';
import '../../progress/ui/progress_home_screen.dart';
import '../../recovery_plan/ui/plan_reveal_screen.dart';
import '../ui/v2_navigation_shell.dart';
import 'v2_shell_tab.dart';

/// Builds the production four-tab StatefulShellRoute for V2.
///
/// Brain Check and Reports are registered outside this shell as contextual routes.
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
            path: V2ShellPaths.plan,
            name: 'v2PlanReveal',
            pageBuilder: (context, state) {
              final planId = state.uri.queryParameters['plan'];
              return NoTransitionPage<void>(
                child: PlanRevealScreen(planId: planId),
              );
            },
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
