import 'dart:io';

import 'package:brain_clean_mobile/core/config/app_config.dart';
import 'package:brain_clean_mobile/core/v2/v2_feature_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(V2FeatureBoundary.clearRuntimeOverride);

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
      expect(V2FeatureBoundary.compileTimeV2Enabled, isFalse);
    });
  });

  group('Release candidate identity', () {
    test('pubspec and AppConfig report 2.0.0 / build 17', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec,
        contains(RegExp(r'^version:\s*2\.0\.0\+17\s*$', multiLine: true)),
      );
      expect(AppConfig.appVersion, '2.0.0');
    });

    test('Android applicationId remains unchanged', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(
        gradle,
        contains('applicationId = "com.example.brain_clean_mobile"'),
      );
      expect(gradle, isNot(contains('applicationIdSuffix')));
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
      expect(File('lib/core/network/supabase_client.dart').existsSync(), isTrue);
      expect(
        File('lib/core/services/supabase_auth_service.dart').existsSync(),
        isFalse,
      );
    });
  });
}
