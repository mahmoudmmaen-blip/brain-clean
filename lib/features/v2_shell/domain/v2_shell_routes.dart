import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../brain_profile/ui/brain_profile_reveal_screen.dart';
import '../../daily_session/ui/today_home_screen.dart';
import '../../progress/ui/progress_home_screen.dart';
import '../../recovery_plan/ui/plan_reveal_screen.dart';
import '../../v2_onboarding/ui/brain_check_entry_boundary_screen.dart';
import '../../v2_reports/ui/measurement_history_screen.dart';
import '../../v2_reports/ui/reports_overview_screen.dart';
import '../../v2_reports/ui/weekly_artifact_detail_screen.dart';
import '../ui/v2_navigation_shell.dart';
import 'v2_shell_tab.dart';

/// Builds the production StatefulShellRoute for V2 (navigation composition only).
StatefulShellRoute buildV2NavigationShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return V2NavigationShell(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.home,
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
            path: V2ShellPaths.check,
            name: 'v2Check',
            pageBuilder: (context, state) {
              final mode = state.uri.queryParameters['mode'] ?? 'lite';
              final source = state.uri.queryParameters['source'] ?? 'shell';
              return NoTransitionPage<void>(
                child: BrainCheckEntryBoundaryScreen(
                  mode: mode,
                  source: source,
                ),
              );
            },
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
            path: V2ShellPaths.reports,
            name: 'v2Reports',
            pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: ReportsOverviewScreen(),
            ),
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
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: V2ShellPaths.profile,
            name: 'v2Profile',
            pageBuilder: (context, state) {
              final session = state.uri.queryParameters['session'];
              return NoTransitionPage<void>(
                child: BrainProfileRevealScreen(sessionId: session),
              );
            },
          ),
        ],
      ),
    ],
  );
}
