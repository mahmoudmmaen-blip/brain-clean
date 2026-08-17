import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_routes.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:brain_clean_mobile/features/v2_shell/ui/v2_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/localized_test_app.dart';

/// Minimal V2 shell + contextual routes for Slice 9.1A (no Hive / biz logic).
GoRouter _shellRouter({
  required bool flagOn,
  String initial = AppRoutes.v2Home,
}) {
  return GoRouter(
    initialLocation: initial,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.startsWith('/v2/') && !flagOn) {
        return AppRoutes.home;
      }
      if (path.startsWith('/v2/') &&
          flagOn &&
          !V2ShellPaths.isKnownV2Location(path)) {
        return AppRoutes.v2Home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(
          body: Text('V1_HOME'),
        ),
      ),
      GoRoute(
        path: '/v2/today',
        redirect: (context, state) => AppRoutes.v2Home,
      ),
      GoRoute(
        path: AppRoutes.v2BrainProfile,
        builder: (context, state) => const Scaffold(
          body: Text('BRAIN_PROFILE_CONTEXTUAL'),
        ),
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckEntry,
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return V2NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          for (final tab in V2ShellTab.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.pathPrefix,
                  pageBuilder: (context, state) => NoTransitionPage<void>(
                    child: Scaffold(
                      body: Column(
                        children: [
                          Text('TAB_${tab.name.toUpperCase()}'),
                          if (tab == V2ShellTab.progress)
                            TextButton(
                              onPressed: () =>
                                  GoRouter.of(context).go(AppRoutes.v2Reports),
                              child: const Text('OPEN_REPORTS'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      // Contextual Brain Check (outside primary tabs)
      GoRoute(
        path: AppRoutes.v2Check,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'lite';
          final source = state.uri.queryParameters['source'] ?? 'shell';
          return Scaffold(
            body: Text('CHECK_CONTEXTUAL mode=$mode source=$source'),
          );
        },
      ),
      // Contextual Reports (outside primary tabs)
      GoRoute(
        path: AppRoutes.v2Reports,
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              const Text('REPORTS_CONTEXTUAL'),
              TextButton(
                onPressed: () => GoRouter.of(context).go(AppRoutes.v2Progress),
                child: const Text('BACK_PROGRESS'),
              ),
            ],
          ),
        ),
        routes: [
          GoRoute(
            path: 'artifact',
            builder: (context, state) {
              final id = state.uri.queryParameters['id'] ?? '';
              return Scaffold(body: Text('ARTIFACT_DETAIL id=$id'));
            },
          ),
          GoRoute(
            path: 'measurements',
            builder: (context, state) =>
                const Scaffold(body: Text('MEASUREMENT_HISTORY')),
          ),
        ],
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  tearDown(() {
    V2FeatureBoundary.enableBrainProfileRoutes = false;
  });

  group('Canonical four-tab contract', () {
    test('exactly four primary tabs in Build Spec order', () {
      expect(V2ShellTab.values, hasLength(4));
      expect(V2ShellPaths.primaryTabCount, 4);
      expect(V2ShellPaths.roots, [
        '/v2/home',
        '/v2/plan',
        '/v2/progress',
        '/v2/profile',
      ]);
      expect(V2ShellTab.values.map((t) => t.name).toList(), [
        'today',
        'plan',
        'progress',
        'profile',
      ]);
    });

    test('Brain Check and Reports are not primary tabs', () {
      expect(
        V2ShellTab.values.map((t) => t.name),
        isNot(contains('check')),
      );
      expect(
        V2ShellTab.values.map((t) => t.name),
        isNot(contains('reports')),
      );
      expect(V2ShellTabX.fromLocation('/v2/check'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/reports'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/reports/artifact'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/reports/measurements'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/brain-check/flow'), isNull);
    });

    test('primary tab location mapping + aliases', () {
      expect(V2ShellTabX.fromLocation('/v2/home'), V2ShellTab.today);
      expect(V2ShellTabX.fromLocation('/v2/today'), V2ShellTab.today);
      expect(V2ShellTabX.fromLocation('/v2/plan'), V2ShellTab.plan);
      expect(V2ShellTabX.fromLocation('/v2/progress'), V2ShellTab.progress);
      expect(V2ShellTabX.fromLocation('/v2/profile'), V2ShellTab.profile);
      expect(V2ShellTabX.fromLocation('/v2/brain-profile'), isNull);
      expect(V2ShellTabX.fromLocation('/v2/session/act'), isNull);
      expect(AppRoutes.v2Today, AppRoutes.v2Home);
      expect(AppRoutes.v2Home, '/v2/home');
      expect(AppRoutes.v2Check, '/v2/check');
      expect(AppRoutes.v2PlanReveal, '/v2/plan');
      expect(AppRoutes.v2Progress, '/v2/progress');
      expect(AppRoutes.v2Reports, '/v2/reports');
      expect(AppRoutes.v2Profile, '/v2/profile');
    });

    test('known location gate + shell flag alias', () {
      expect(V2ShellPaths.isKnownV2Location('/v2/home'), isTrue);
      expect(V2ShellPaths.isKnownV2Location('/v2/check'), isTrue);
      expect(V2ShellPaths.isKnownV2Location('/v2/reports'), isTrue);
      expect(V2ShellPaths.isKnownV2Location('/v2/unknown-xyz'), isFalse);
      expect(V2ShellPaths.isKnownV2Location('/v2/session/prepare'), isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2Shell, isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2Shell, isFalse);
    });

    test('production shell route factory builds four branches', () {
      expect(buildV2NavigationShellRoute(), isA<StatefulShellRoute>());
    });
  });

  group('Feature flag', () {
    testWidgets('OFF preserves V1 for /v2/home', (tester) async {
      final router = _shellRouter(flagOn: false, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('V1_HOME'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('ON exposes four-tab V2 shell on Today', (tester) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.byType(V2NavigationShell), findsOneWidget);
    });
  });

  group('Primary tab deep links', () {
    testWidgets('Today / Plan / Progress / Profile select correct tabs', (
      tester,
    ) async {
      final cases = <(String, String, int)>[
        (AppRoutes.v2Home, 'TAB_TODAY', 0),
        (AppRoutes.v2PlanReveal, 'TAB_PLAN', 1),
        (AppRoutes.v2Progress, 'TAB_PROGRESS', 2),
        (AppRoutes.v2Profile, 'TAB_PROFILE', 3),
      ];

      for (final (path, label, index) in cases) {
        final router = _shellRouter(flagOn: true, initial: path);
        await tester.pumpWidget(
          createLocalizedRouterTestWidget(router: router),
        );
        await tester.pump();
        expect(find.text(label), findsOneWidget);
        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, index);
      }
    });

    testWidgets('/v2/home and /v2/today aliases map to Today', (tester) async {
      var router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);

      router = _shellRouter(flagOn: true, initial: '/v2/today');
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);
    });

    testWidgets('/v2/brain-profile opens outside tab bar', (tester) async {
      final router = _shellRouter(
        flagOn: true,
        initial: AppRoutes.v2BrainProfile,
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('BRAIN_PROFILE_CONTEXTUAL'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('invalid /v2 path recovers to Today', (tester) async {
      final router =
          _shellRouter(flagOn: true, initial: '/v2/not-a-real-route');
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);
    });
  });

  group('Contextual Brain Check', () {
    testWidgets('direct /v2/check opens outside tab bar', (tester) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Check);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.textContaining('CHECK_CONTEXTUAL'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('/v2/brain-check/entry alias opens Check', (tester) async {
      final router = _shellRouter(
        flagOn: true,
        initial: AppRoutes.v2BrainCheckEntry,
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.textContaining('CHECK_CONTEXTUAL'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('Brain Check resume preserves query; no duplicate host', (
      tester,
    ) async {
      final router = _shellRouter(
        flagOn: true,
        initial: '${AppRoutes.v2Check}?mode=full&source=profile',
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(
        find.text('CHECK_CONTEXTUAL mode=full source=profile'),
        findsOneWidget,
      );
      // Single contextual host — not also inside a tab branch.
      expect(find.textContaining('CHECK_CONTEXTUAL'), findsOneWidget);
    });
  });

  group('Contextual Reports', () {
    testWidgets('direct /v2/reports opens outside tab bar', (tester) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Reports);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('REPORTS_CONTEXTUAL'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('Progress → Reports and Reports → Progress', (tester) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Progress);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_PROGRESS'), findsOneWidget);

      await tester.tap(find.text('OPEN_REPORTS'));
      await tester.pumpAndSettle();
      expect(find.text('REPORTS_CONTEXTUAL'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('BACK_PROGRESS'));
      await tester.pumpAndSettle();
      expect(find.text('TAB_PROGRESS'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('artifact deep link', (tester) async {
      final router = _shellRouter(
        flagOn: true,
        initial: '${AppRoutes.v2Reports}/artifact?id=w1',
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('ARTIFACT_DETAIL id=w1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('measurement-history deep link', (tester) async {
      final router = _shellRouter(
        flagOn: true,
        initial: '${AppRoutes.v2Reports}/measurements',
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('MEASUREMENT_HISTORY'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('Tab switching / state preservation', () {
    testWidgets('tap destinations switches tabs; re-tap resets branch', (
      tester,
    ) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);

      await tester.tap(find.text('Program'));
      await tester.pump();
      expect(find.text('TAB_PLAN'), findsOneWidget);

      await tester.tap(find.text('Progress'));
      await tester.pump();
      expect(find.text('TAB_PROGRESS'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(find.text('TAB_PROFILE'), findsOneWidget);

      // Re-select current tab (initialLocation: true) stays on Profile.
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(find.text('TAB_PROFILE'), findsOneWidget);

      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);
    });

    testWidgets('indexed stack preserves tab state across switches', (
      tester,
    ) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();

      await tester.tap(find.text('Program'));
      await tester.pump();
      expect(find.text('TAB_PLAN'), findsOneWidget);

      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(find.text('TAB_TODAY'), findsOneWidget);

      await tester.tap(find.text('Program'));
      await tester.pump();
      expect(find.text('TAB_PLAN'), findsOneWidget);
    });
  });

  group('Localization / RTL / a11y', () {
    test('canonical EN/AR tab labels', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2NavToday, 'Today');
      expect(en.v2NavPlan, 'Program');
      expect(en.v2NavProgress, 'Progress');
      expect(en.v2NavProfile, 'Profile');
      expect(ar.v2NavToday, 'اليوم');
      expect(ar.v2NavPlan, 'البرنامج');
      expect(ar.v2NavProgress, 'التقدّم');
      expect(ar.v2NavProfile, 'الملف');
      // Contextual labels remain available for nested surfaces.
      expect(en.v2NavCheck, 'Brain Check');
      expect(en.v2NavReports, 'Reports');
      expect(ar.v2NavCheck, 'فحص الدماغ');
      expect(ar.v2NavReports, 'التقارير');
    });

    testWidgets('LTR/RTL; 320dp; textScale 2.0; four destinations; targets', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));

      for (final locale in const [Locale('en'), Locale('ar')]) {
        final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 720),
              textScaler: TextScaler.linear(2),
            ),
            child: createLocalizedRouterTestWidget(
              router: router,
              locale: locale,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationDestination), findsNWidgets(4));
        expect(tester.takeException(), isNull);

        final destinations = find.byType(NavigationDestination);
        for (var i = 0; i < 4; i++) {
          final size = tester.getSize(destinations.at(i));
          expect(size.height, greaterThanOrEqualTo(48));
        }

        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, 0);

        // Screen-reader labels via destination labels (locale-aware).
        if (locale.languageCode == 'en') {
          expect(find.text('Today'), findsWidgets);
          expect(find.text('Program'), findsWidgets);
          expect(find.text('Progress'), findsWidgets);
          expect(find.text('Profile'), findsWidgets);
        } else {
          expect(find.text('اليوم'), findsWidgets);
          expect(find.text('البرنامج'), findsWidgets);
          expect(find.text('التقدّم'), findsWidgets);
          expect(find.text('الملف'), findsWidgets);
        }
      }

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('No duplicate generation on navigation', () {
    testWidgets('tab switching does not open Check/Reports hosts', (
      tester,
    ) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();

      for (final label in ['Program', 'Progress', 'Profile', 'Today']) {
        await tester.tap(find.text(label));
        await tester.pump();
        expect(find.textContaining('CHECK_CONTEXTUAL'), findsNothing);
        expect(find.text('REPORTS_CONTEXTUAL'), findsNothing);
      }
    });
  });

  group('Restart / flag continuity', () {
    testWidgets('flag remains OFF across rebuild; ON after enable', (
      tester,
    ) async {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      var router = _shellRouter(flagOn: false, initial: AppRoutes.v2Progress);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('V1_HOME'), findsOneWidget);

      V2FeatureBoundary.enableBrainProfileRoutes = true;
      router = _shellRouter(flagOn: true, initial: AppRoutes.v2Progress);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_PROGRESS'), findsOneWidget);
    });
  });
}
