import 'dart:io';

import 'package:brain_clean_mobile/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.appVersion', () {
    test('matches pubspec.yaml version name (before +build)', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match =
          RegExp(r'^version:\s*([^\s+]+)', multiLine: true).firstMatch(pubspec);
      expect(match, isNotNull);
      expect(AppConfig.appVersion, match!.group(1));
    });
  });

  group('AppConfig.isPlaceholderConfigValue', () {
    test('detects common documentation placeholders', () {
      expect(
        AppConfig.isPlaceholderConfigValue(
          'https://your-project-ref.supabase.co',
        ),
        isTrue,
      );
      expect(
        AppConfig.isPlaceholderConfigValue('sb_publishable_your_key_here'),
        isTrue,
      );
      expect(
        AppConfig.isPlaceholderConfigValue(
          'your_revenuecat_public_api_key_here',
        ),
        isTrue,
      );
      expect(
        AppConfig.isPlaceholderConfigValue('your-anon-key'),
        isTrue,
      );
      expect(
        AppConfig.isPlaceholderConfigValue('your-revenuecat-key'),
        isTrue,
      );
    });

    test('does not flag empty as placeholder (treated as missing)', () {
      expect(AppConfig.isPlaceholderConfigValue(''), isFalse);
      expect(AppConfig.isPlaceholderConfigValue('   '), isFalse);
    });

    test('accepts realistic non-placeholder shapes', () {
      expect(
        AppConfig.isPlaceholderConfigValue(
          'https://abcdefghijklmnop.supabase.co',
        ),
        isFalse,
      );
      expect(
        AppConfig.isPlaceholderConfigValue('goog_AbCdEfGhIjKlMnOpQrStUv'),
        isFalse,
      );
    });
  });

  group('AppConfig.configPresenceLabel', () {
    test('never echoes the full secret', () {
      const key = 'goog_SuperSecretKeyValue123456';
      final label = AppConfig.configPresenceLabel(key);
      expect(label, isNot(contains(key)));
      expect(label, contains('set(len='));
      expect(label, contains('goog'));
    });

    test('reports missing for empty', () {
      expect(AppConfig.configPresenceLabel(''), 'missing');
    });
  });

  group('AppConfig without dart-defines', () {
    test('Supabase and RevenueCat look invalid when only placeholders exist', () {
      expect(AppConfig.hasValidSupabaseConfig, isFalse);
      expect(AppConfig.hasValidRevenueCatApiKey, isFalse);
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.revenueCatApiKey, isEmpty);
    });
  });
}
