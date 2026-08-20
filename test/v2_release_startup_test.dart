import 'dart:io';

import 'package:brain_clean_mobile/core/config/app_config.dart';
import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/core/routing/startup_destination.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:brain_clean_mobile/features/v2_shell/ui/v2_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/localized_test_app.dart';

/// Stub four-tab shell for startup routing tests (no Hive / session deps).
GoRouter _startupShellRouter({
  required bool flagOn,
  required String initial,
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
        builder: (context, state) => const Scaffold(body: Text('V1_HOME')),
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
                    child:
                        Scaffold(body: Text('TAB_${tab.name.toUpperCase()}')),
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
  tearDown(V2FeatureBoundary.clearRuntimeOverride);

  group('StartupDestination resolver', () {
    test('V2 enabled → /v2/home', () {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(StartupDestination.resolve(), AppRoutes.v2Home);
      expect(StartupDestination.resolve(), '/v2/home');
    });

    test('V2 disabled → /home', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(StartupDestination.resolve(), AppRoutes.home);
      expect(StartupDestination.resolve(), '/home');
    });

    test('resolver shares enableV2Shell / compile-time gate', () {
      // Runtime override stands in for --dart-define=V2_ENABLED=true.
      // Release binaries embed the same gate via compileTimeV2Enabled.
      V2FeatureBoundary.clearRuntimeOverride();
      expect(
        V2FeatureBoundary.enableV2Shell,
        V2FeatureBoundary.compileTimeV2Enabled,
      );

      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2Shell, isTrue);
      expect(StartupDestination.resolve(), AppRoutes.v2Home);

      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2Shell, isFalse);
      expect(StartupDestination.resolve(), AppRoutes.home);
    });

    test('V2 enabled → /v2/onboarding; V2 disabled → /onboarding', () {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(StartupDestination.onboarding(), AppRoutes.v2Onboarding);
      expect(StartupDestination.onboarding(), '/v2/onboarding');

      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(StartupDestination.onboarding(), AppRoutes.onboarding);
      expect(StartupDestination.onboarding(), '/onboarding');
    });

    test('V2 first-time redirect keeps Check/Plan path; blocks V1 Home', () {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/v2/onboarding'),
        isNull,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/v2/check'),
        isNull,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete(
          '/v2/check?mode=lite&source=onboarding',
        ),
        isNull,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/v2/plan/building'),
        isNull,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/onboarding'),
        AppRoutes.v2Onboarding,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/home'),
        AppRoutes.v2Onboarding,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/v2/home'),
        AppRoutes.v2Onboarding,
      );
    });

    test('V2 disabled first-time redirect stays on V1 onboarding', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/onboarding'),
        isNull,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/home'),
        AppRoutes.onboarding,
      );
      expect(
        StartupDestination.redirectIfOnboardingIncomplete('/v2/onboarding'),
        AppRoutes.onboarding,
      );
    });

    test('source: StartupDestination.resolve uses enableV2Shell', () {
      final src =
          File('lib/core/routing/startup_destination.dart').readAsStringSync();
      expect(src, contains('V2FeatureBoundary.enableV2Shell'));
      expect(src, contains('AppRoutes.v2Home'));
      expect(src, contains('AppRoutes.home'));
      expect(src, contains('AppRoutes.v2Onboarding'));
      expect(src, contains('redirectIfOnboardingIncomplete'));
    });
  });

  group('Splash and biometric use StartupDestination', () {
    test('splash first-run uses StartupDestination.onboarding', () {
      final src = File('lib/features/splash/presentation/splash_screen.dart')
          .readAsStringSync();
      expect(src, contains('StartupDestination.onboarding()'));
      expect(src, isNot(contains('context.go(AppRoutes.onboarding)')));
    });

    test('splash ordinary completion uses StartupDestination.resolve', () {
      final src = File('lib/features/splash/presentation/splash_screen.dart')
          .readAsStringSync();
      expect(src, contains('startup_destination.dart'));
      expect(src, contains('StartupDestination.resolve()'));
      expect(src, contains('AppRoutes.diagnostic'));
      expect(
        src,
        isNot(
          contains(
            'resumeLiveSession ? AppRoutes.diagnostic : AppRoutes.home',
          ),
        ),
      );
    });

    test('biometric unlock uses StartupDestination.resolve', () {
      final src = File('lib/core/routing/app_router.dart').readAsStringSync();
      expect(src, contains('startup_destination.dart'));
      expect(src, contains('StartupDestination.resolve()'));
      expect(src, contains('StartupDestination.onboarding()'));
      expect(src, contains('redirectIfOnboardingIncomplete'));
      expect(
        src,
        isNot(
          contains(
            'if (!prefs.hasSeenOnboarding && location != AppRoutes.onboarding) {\n'
            '        return AppRoutes.onboarding;',
          ),
        ),
      );
      expect(
        src,
        isNot(
          contains(
            'if (biometricUnlocked && location == AppRoutes.biometricLock) {\n'
            '        return AppRoutes.home;',
          ),
        ),
      );
    });

    test('biometric lock button uses StartupDestination not V1 /home', () {
      final src = File('lib/core/security/biometric_lock_screen.dart')
          .readAsStringSync();
      expect(src, contains('StartupDestination.resolve()'));
      expect(src, isNot(contains('AppRoutes.home')));
    });

    test('V2 onboarding Start Brain Check still hands off to /v2/check', () {
      final src =
          File('lib/features/v2_onboarding/ui/v2_onboarding_flow_screen.dart')
              .readAsStringSync();
      expect(src, contains('AppRoutes.v2BrainCheckEntry'));
      expect(src, contains('mode=lite'));
      expect(src, contains('source=onboarding'));
      expect(src, contains('StartupDestination.resolve()'));
      expect(src, isNot(contains('AppRoutes.home')));
    });

    test(
        'Today-ready completion marks V1 hasSeenOnboarding for returning users',
        () {
      final src = File(
        'lib/features/recovery_plan/ui/plan_today_ready_boundary_screen.dart',
      ).readAsStringSync();
      expect(src, contains('completeOnboarding()'));
      expect(src, contains('markJourneyCompleted'));
    });
  });

  group('First-time V2 journey routing', () {
    GoRouter firstTimeRouter({
      required bool hasSeenOnboarding,
      required String initial,
    }) {
      return GoRouter(
        initialLocation: initial,
        redirect: (context, state) {
          final location = state.uri.path;
          if (location.startsWith('/v2/') && !V2FeatureBoundary.enableV2Shell) {
            return AppRoutes.home;
          }
          if (!hasSeenOnboarding) {
            return StartupDestination.redirectIfOnboardingIncomplete(location);
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('V1_HOME')),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (_, __) => const Scaffold(body: Text('V1_ONBOARDING')),
          ),
          GoRoute(
            path: AppRoutes.v2Onboarding,
            builder: (_, __) => const Scaffold(body: Text('V2_ONBOARDING')),
          ),
          GoRoute(
            path: AppRoutes.v2Check,
            builder: (_, __) => const Scaffold(body: Text('V2_CHECK')),
          ),
          GoRoute(
            path: AppRoutes.v2Home,
            builder: (_, __) => const Scaffold(body: Text('V2_TODAY')),
          ),
        ],
      );
    }

    testWidgets('V2 fresh install: /home and /onboarding become /v2/onboarding',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      final router = firstTimeRouter(
        hasSeenOnboarding: false,
        initial: AppRoutes.home,
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      await tester.pump();

      expect(find.text('V2_ONBOARDING'), findsOneWidget);
      expect(find.text('V1_ONBOARDING'), findsNothing);
      expect(find.text('V1_HOME'), findsNothing);

      router.go(AppRoutes.onboarding);
      await tester.pump();
      await tester.pump();
      expect(find.text('V2_ONBOARDING'), findsOneWidget);
      expect(find.text('V1_ONBOARDING'), findsNothing);
    });

    testWidgets('V2 onboarding Start Brain Check path stays on /v2/check',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      final router = firstTimeRouter(
        hasSeenOnboarding: false,
        initial: AppRoutes.v2Onboarding,
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      expect(find.text('V2_ONBOARDING'), findsOneWidget);

      router.go('${AppRoutes.v2Check}?mode=lite&source=onboarding');
      await tester.pump();
      await tester.pump();
      expect(find.text('V2_CHECK'), findsOneWidget);
      expect(find.text('V1_HOME'), findsNothing);
    });

    testWidgets('V2 returning user stays on /v2/home', (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      final router = firstTimeRouter(
        hasSeenOnboarding: true,
        initial: StartupDestination.resolve(),
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      await tester.pump();

      expect(find.text('V2_TODAY'), findsOneWidget);
      expect(find.text('V1_HOME'), findsNothing);
      expect(find.text('V2_ONBOARDING'), findsNothing);
    });

    testWidgets('V2 disabled fresh install still uses V1 onboarding',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      final router = firstTimeRouter(
        hasSeenOnboarding: false,
        initial: AppRoutes.home,
      );
      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pump();
      await tester.pump();

      expect(find.text('V1_ONBOARDING'), findsOneWidget);
      expect(find.text('V2_ONBOARDING'), findsNothing);
      expect(find.text('V1_HOME'), findsNothing);
    });
  });

  group('V2 shell and V1 preservation', () {
    testWidgets(
        'V2 enabled shows five-tab shell Home·Exercises·Progress·Pro·Profile',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      final en = AppLocalizationsEn();
      final router = _startupShellRouter(
        flagOn: true,
        initial: StartupDestination.resolve(),
      );

      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(V2NavigationShell), findsOneWidget);
      expect(find.text(en.v2NavHome), findsOneWidget);
      expect(find.text(en.v2NavExercises), findsOneWidget);
      expect(find.text(en.v2NavProgress), findsOneWidget);
      expect(find.text(en.v2NavPro), findsOneWidget);
      expect(find.text(en.v2NavProfile), findsOneWidget);
      expect(en.v2NavHome, 'Home');
      expect(en.v2NavExercises, 'Exercises');
      expect(en.v2NavProgress, 'Progress');
      expect(en.v2NavPro, 'Pro');
      expect(en.v2NavProfile, 'Profile');
      expect(V2ShellTab.values.length, 5);
    });

    testWidgets('V2 disabled preserves V1 Home destination', (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(StartupDestination.resolve(), AppRoutes.home);

      final router = _startupShellRouter(
        flagOn: false,
        initial: StartupDestination.resolve(),
      );

      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();

      expect(find.text('V1_HOME'), findsOneWidget);
      expect(find.byType(V2NavigationShell), findsNothing);
    });

    testWidgets('unknown V2 routes recover to /v2/home without loop',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      var redirectCount = 0;
      final router = GoRouter(
        initialLocation: '/v2/not-a-real-route',
        redirect: (context, state) {
          redirectCount++;
          expect(redirectCount, lessThan(6), reason: 'routing loop');
          final path = state.uri.path;
          if (path.startsWith('/v2/') && !V2FeatureBoundary.enableV2Shell) {
            return AppRoutes.home;
          }
          if (path.startsWith('/v2/') &&
              V2FeatureBoundary.enableV2Shell &&
              !V2ShellPaths.isKnownV2Location(path)) {
            return AppRoutes.v2Home;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('V1_HOME')),
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

      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/v2/home');
      expect(find.byType(V2NavigationShell), findsOneWidget);
    });

    testWidgets('V2 disabled: /v2/* redirects to V1 Home without loop',
        (tester) async {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      var redirectCount = 0;
      final router = GoRouter(
        initialLocation: AppRoutes.v2Home,
        redirect: (context, state) {
          redirectCount++;
          expect(redirectCount, lessThan(6), reason: 'routing loop');
          final path = state.uri.path;
          if (path.startsWith('/v2/') && !V2FeatureBoundary.enableV2Shell) {
            return AppRoutes.home;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('V1_HOME')),
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

      await tester.pumpWidget(createLocalizedRouterTestWidget(router: router));
      await tester.pumpAndSettle();

      expect(find.text('V1_HOME'), findsOneWidget);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
    });
  });

  group('V2 release enablement', () {
    test('runtime override OFF preserves V1 gate behavior', () {
      V2FeatureBoundary.enableBrainProfileRoutes = false;
      expect(V2FeatureBoundary.enableV2Shell, isFalse);
      expect(V2FeatureBoundary.enableReportsRoutes, isFalse);
      expect(V2FeatureBoundary.enableTodaySessionRoutes, isFalse);
    });

    test('runtime override ON enables V2 shell routes', () {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableV2Shell, isTrue);
      expect(V2FeatureBoundary.enableReportsRoutes, isTrue);
      expect(V2FeatureBoundary.enableTodaySessionRoutes, isTrue);
      expect(V2FeatureBoundary.enableRecoveryPlanRoutes, isTrue);
    });

    test('clearRuntimeOverride restores compile-time resolution', () {
      V2FeatureBoundary.enableBrainProfileRoutes = true;
      expect(V2FeatureBoundary.enableBrainProfileRoutes, isTrue);
      V2FeatureBoundary.clearRuntimeOverride();
      expect(
        V2FeatureBoundary.enableBrainProfileRoutes,
        V2FeatureBoundary.compileTimeV2Enabled,
      );
    });

    test('compile-time V2_ENABLED defaults false in unit test binary', () {
      // Suite runs without --dart-define=V2_ENABLED=true.
      // Release AAB passes the define at flutter build time.
      // This does not replace a real release-device smoke test.
      expect(V2FeatureBoundary.compileTimeV2Enabled, isFalse);
    });
  });

  group('Release candidate identity', () {
    test('pubspec and AppConfig report 2.0.1 / build 24', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec,
        contains(RegExp(r'^version:\s*2\.0\.1\+24\s*$', multiLine: true)),
      );
      expect(AppConfig.appVersion, '2.0.1');
    });

    test('Android applicationId matches Google Play package', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(
        gradle,
        contains('applicationId = "com.brainclean.mobile"'),
      );
      expect(
        gradle,
        contains('namespace = "com.brainclean.mobile"'),
      );
      expect(gradle, isNot(contains('com.example.brain_clean_mobile')));
      expect(gradle, isNot(contains('applicationIdSuffix')));
    });
  });

  group('Root Play build authority', () {
    test('ROOT_BUILD_AUTHORITY.md documents root-only Play builds', () {
      final doc = File('docs/ROOT_BUILD_AUTHORITY.md').readAsStringSync();
      expect(doc, contains('repository root'));
      expect(doc, contains('pubspec.yaml'));
      expect(doc, contains('android'));
      expect(doc, contains('brain_clean_mobile/'));
      expect(doc.toLowerCase(), contains('never build'));
      expect(doc, contains('com.brainclean.mobile'));
      expect(doc, contains('V2_ENABLED=true'));
    });
  });

  group('Ads deferred / RC log redaction / notifications shrinker', () {
    test('root pubspec does not depend on google_mobile_ads', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('google_mobile_ads')));
    });

    test('root lib does not initialize AdsService / Mobile Ads', () {
      final mainSrc = File('lib/main.dart').readAsStringSync();
      expect(mainSrc, isNot(contains('AdsService')));
      expect(mainSrc, isNot(contains('MobileAds')));
      expect(mainSrc, isNot(contains('google_mobile_ads')));

      final hits = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final text = entity.readAsStringSync();
        if (text.contains('AdsService:') ||
            text.contains('Mobile Ads initialized') ||
            text.contains('package:google_mobile_ads/')) {
          hits.add(entity.path);
        }
      }
      expect(hits, isEmpty);
    });

    test('RC presence labels never expose len/prefix/key material', () {
      const samples = <String>[
        'goog_test_public_sdk_key_value_here',
        'super-secret-key',
        '',
        'your_revenuecat_key',
      ];
      for (final sample in samples) {
        final label = AppConfig.configPresenceLabel(sample);
        expect(label, anyOf('configured', 'unavailable'));
        expect(label, isNot(contains('len=')));
        expect(label, isNot(contains('prefix=')));
        expect(label, isNot(contains('set(')));
        if (sample.isNotEmpty) {
          expect(label, isNot(contains(sample)));
        }
      }
    });

    test('release ProGuard rules retain Gson TypeToken signatures', () {
      final rules = File('android/app/proguard-rules.pro').readAsStringSync();
      expect(rules, contains('-keepattributes Signature'));
      expect(rules, contains('com.google.gson.reflect.TypeToken'));
      expect(rules, contains('com.dexterous.flutterlocalnotifications'));
    });

    test('release buildType enables minify with proguard-rules', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(gradle, contains('isMinifyEnabled = true'));
      expect(gradle, contains('proguard-rules.pro'));
    });
  });

  group('Supabase startup classification', () {
    test('root main initializes SupabaseConfig once; no anonymous auth service',
        () {
      final mainSrc = File('lib/main.dart').readAsStringSync();
      expect('SupabaseConfig.initialize'.allMatches(mainSrc).length, 1);
      expect(mainSrc, isNot(contains('signInAnonymously')));
      expect(mainSrc, isNot(contains('SupabaseAuthService')));
      expect(
          File('lib/core/network/supabase_client.dart').existsSync(), isTrue);
      expect(
        File('lib/core/services/supabase_auth_service.dart').existsSync(),
        isFalse,
      );
    });
  });
}
