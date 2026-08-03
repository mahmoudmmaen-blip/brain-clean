import 'package:brain_clean_mobile/core/application/app_preferences_provider.dart';
import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_color_theme.dart';
import 'package:brain_clean_mobile/core/theme/app_color_theme_provider.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

ProviderContainer _container({
  Map<String, dynamic>? seed,
  bool isPro = false,
}) {
  final container = ProviderContainer(
    overrides: [
      // Theme gating tests exercise the local fake adapter + preferences only.
      forceLocalSubscriptionAdapterProvider.overrideWithValue(true),
      appMetaBoxProvider.overrideWithValue(InMemoryHiveBox(seed)),
      appPreferencesProvider.overrideWith(
        () => isPro ? _ProPreferences() : _FreePreferences(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('SelectedColorThemeNotifier / effectiveColorThemeProvider', () {
    test('defaults to midnight when no key stored', () {
      expect(
        _container().read(selectedColorThemeProvider),
        AppColorTheme.midnight,
      );
    });

    test('restores persisted theme from Hive on build', () {
      final c = _container(
        seed: {
          HiveMetaKeys.selectedColorThemeId: AppColorTheme.aurora.name,
        },
      );
      expect(c.read(selectedColorThemeProvider), AppColorTheme.aurora);
    });

    test('pro user keeps a pro theme as effective', () async {
      final c = _container(isPro: true);
      await c.read(selectedColorThemeProvider.notifier).select(AppColorTheme.pine);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.pine);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.pine);
    });

    test('free user selecting a pro theme falls back effectively to midnight',
        () async {
      final c = _container(isPro: false);
      await c.read(selectedColorThemeProvider.notifier).select(AppColorTheme.pine);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.pine);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.midnight);
    });

    test('free user can keep a free theme', () async {
      final c = _container(isPro: false);
      await c
          .read(selectedColorThemeProvider.notifier)
          .select(AppColorTheme.aurora);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.aurora);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.aurora);
    });
  });
}

class _FreePreferences extends AppPreferences {
  @override
  AppPreferencesState build() => const AppPreferencesState(
        hasSeenOnboarding: true,
        isProUser: false,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: true,
        profileDisplayName: '',
        silenceWinsCount: 0,
        singleTasksCompletedCount: 0,
      );
}

class _ProPreferences extends AppPreferences {
  @override
  AppPreferencesState build() => const AppPreferencesState(
        hasSeenOnboarding: true,
        isProUser: true,
        emotionNotificationsEnabled: true,
        dailyFocusReminderEnabled: true,
        profileDisplayName: '',
        silenceWinsCount: 0,
        singleTasksCompletedCount: 0,
      );
}
