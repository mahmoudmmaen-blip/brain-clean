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

/// Minimal V2 shell router for Slice 9.1 navigation tests (no Hive / biz logic).
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
        redirect: (context, state) => AppRoutes.v2Profile,
      ),
      GoRoute(
        path: AppRoutes.v2BrainCheckEntry,
        redirect: (context, state) => AppRoutes.v2Check,
      ),
      // Lightweight shell stand-ins (avoid Hive-backed product screens).
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
                      body: Text('TAB_${tab.name.toUpperCase()}'),
                    ),
                  ),
                ),
              ],
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

  group('V2ShellTab / paths', () {
    test('six roots and location mapping', () {
      expect(V2ShellPaths.roots, hasLength(6));
      expect(V2ShellTabX.fromLocation('/v2/home'), V2ShellTab.home);
      expect(V2ShellTabX.fromLocation('/v2/today'), V2ShellTab.home);
      expect(V2ShellTabX.fromLocation('/v2/check'), V2ShellTab.check);
      expect(V2ShellTabX.fromLocation('/v2/plan'), V2ShellTab.plan);
      expect(V2ShellTabX.fromLocation('/v2/progress'), V2ShellTab.progress);
      expect(V2ShellTabX.fromLocation('/v2/reports'), V2ShellTab.reports);
      expect(
        V2ShellTabX.fromLocation('/v2/reports/artifact'),
        V2ShellTab.reports,
      );
      expect(V2ShellTabX.fromLocation('/v2/profile'), V2ShellTab.profile);
      expect(
        V2ShellTabX.fromLocation('/v2/brain-profile'),
        V2ShellTab.profile,
      );
      expect(V2ShellTabX.fromLocation('/v2/session/act'), isNull);
      expect(AppRoutes.v2Today, AppRoutes.v2Home);
      expect(AppRoutes.v2Home, '/v2/home');
      expect(AppRoutes.v2Check, '/v2/check');
      expect(AppRoutes.v2Profile, '/v2/profile');
    });

    test('known location gate + shell flag alias', () {
      expect(V2ShellPaths.isKnownV2Location('/v2/home'), isTrue);
      expect(V2ShellPaths.isKnownV2Location('/v2/unknown-xyz'), isFalse);
      expect(V2ShellPaths.isKnownV2Location('/v2/session/prepare'), isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2Shell, isTrue);
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2Shell, isFalse);
    });

    test('production shell route factory builds', () {
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

    testWidgets('ON enters V2 shell Home tab', (tester) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_HOME'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(V2NavigationShell), findsOneWidget);
    });
  });

  group('Deep links', () {
    testWidgets('each shell deep link selects correct tab', (tester) async {
      final paths = [
        AppRoutes.v2Home,
        AppRoutes.v2Check,
        AppRoutes.v2PlanReveal,
        AppRoutes.v2Progress,
        AppRoutes.v2Reports,
        AppRoutes.v2Profile,
      ];
      final labels = [
        'TAB_HOME',
        'TAB_CHECK',
        'TAB_PLAN',
        'TAB_PROGRESS',
        'TAB_REPORTS',
        'TAB_PROFILE',
      ];

      for (var i = 0; i < paths.length; i++) {
        final router = _shellRouter(flagOn: true, initial: paths[i]);
        await tester.pumpWidget(
          createLocalizedRouterTestWidget(router: router),
        );
        await tester.pump();
        expect(find.text(labels[i]), findsOneWidget);
        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, i);
      }
    });

    testWidgets('legacy aliases redirect into shell tabs', (tester) async {
      var router = _shellRouter(flagOn: true, initial: '/v2/today');
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_HOME'), findsOneWidget);

      router = _shellRouter(flagOn: true, initial: AppRoutes.v2BrainCheckEntry);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_CHECK'), findsOneWidget);

      router = _shellRouter(flagOn: true, initial: AppRoutes.v2BrainProfile);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_PROFILE'), findsOneWidget);
    });

    testWidgets('invalid /v2 path recovers to Home', (tester) async {
      final router = _shellRouter(flagOn: true, initial: '/v2/not-a-real-route');
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_HOME'), findsOneWidget);
    });
  });

  group('Tab switching / back stack', () {
    testWidgets('tap destinations switches tabs and re-tap resets branch', (
      tester,
    ) async {
      final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('TAB_HOME'), findsOneWidget);

      await tester.tap(find.text('Progress'));
      await tester.pump();
      expect(find.text('TAB_PROGRESS'), findsOneWidget);

      await tester.tap(find.text('Reports'));
      await tester.pump();
      expect(find.text('TAB_REPORTS'), findsOneWidget);

      // Re-select current tab (initialLocation: true) stays on Reports.
      await tester.tap(find.text('Reports'));
      await tester.pump();
      expect(find.text('TAB_REPORTS'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.text('TAB_HOME'), findsOneWidget);
    });
  });

  group('Localization / RTL / a11y', () {
    test('EN/AR tab labels present', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2NavHome, 'Home');
      expect(en.v2NavCheck, 'Brain Check');
      expect(en.v2NavPlan, 'Plan');
      expect(en.v2NavProgress, 'Progress');
      expect(en.v2NavReports, 'Reports');
      expect(en.v2NavProfile, 'Profile');
      expect(ar.v2NavHome, 'الرئيسية');
      expect(ar.v2NavCheck, 'فحص الدماغ');
      expect(ar.v2NavPlan, 'الخطة');
      expect(ar.v2NavProgress, 'التقدّم');
      expect(ar.v2NavReports, 'التقارير');
      expect(ar.v2NavProfile, 'الملف');
    });

    testWidgets('LTR and RTL shell; 320dp + textScale 2.0', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));

      for (final locale in const [Locale('en'), Locale('ar')]) {
        final router = _shellRouter(flagOn: true, initial: AppRoutes.v2Home);
        await tester.pumpWidget(
          createLocalizedRouterTestWidget(
            router: router,
            locale: locale,
          ),
        );
        await tester.pump();
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
        expect(find.byType(NavigationDestination), findsNWidgets(6));
      }

      await tester.binding.setSurfaceSize(null);
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
