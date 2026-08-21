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
    test('defaults to dark when no key stored', () {
      expect(
        _container().read(selectedColorThemeProvider),
        AppColorTheme.dark,
      );
    });

    test('selecting dark, light, and amoled updates providers', () async {
      final c = _container();
      await c.read(selectedColorThemeProvider.notifier).select(AppColorTheme.light);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.light);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.light);

      await c.read(selectedColorThemeProvider.notifier).select(AppColorTheme.dark);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.dark);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.dark);

      await c
          .read(selectedColorThemeProvider.notifier)
          .select(AppColorTheme.amoled);
      expect(c.read(selectedColorThemeProvider), AppColorTheme.amoled);
      expect(c.read(effectiveColorThemeProvider), AppColorTheme.amoled);
    });

    test('dark, light, and amoled are accessible without Pro', () async {
      final free = _container(isPro: false);
      await free
          .read(selectedColorThemeProvider.notifier)
          .select(AppColorTheme.light);
      expect(free.read(selectedColorThemeProvider), AppColorTheme.light);
      expect(free.read(effectiveColorThemeProvider), AppColorTheme.light);

      await free
          .read(selectedColorThemeProvider.notifier)
          .select(AppColorTheme.dark);
      expect(free.read(selectedColorThemeProvider), AppColorTheme.dark);
      expect(free.read(effectiveColorThemeProvider), AppColorTheme.dark);

      await free
          .read(selectedColorThemeProvider.notifier)
          .select(AppColorTheme.amoled);
      expect(free.read(selectedColorThemeProvider), AppColorTheme.amoled);
      expect(free.read(effectiveColorThemeProvider), AppColorTheme.amoled);
    });

    test('legacy persisted names map to dark, light, or amoled', () {
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'midnight',
        }).read(selectedColorThemeProvider),
        AppColorTheme.dark,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'aurora',
        }).read(selectedColorThemeProvider),
        AppColorTheme.dark,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'daylight',
        }).read(selectedColorThemeProvider),
        AppColorTheme.light,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'light',
        }).read(selectedColorThemeProvider),
        AppColorTheme.light,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'black',
        }).read(selectedColorThemeProvider),
        AppColorTheme.amoled,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'amoled',
        }).read(selectedColorThemeProvider),
        AppColorTheme.amoled,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'pureWhite',
        }).read(selectedColorThemeProvider),
        AppColorTheme.pureWhite,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'white',
        }).read(selectedColorThemeProvider),
        AppColorTheme.pureWhite,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'warmBeige',
        }).read(selectedColorThemeProvider),
        AppColorTheme.warmBeige,
      );
      expect(
        _container(seed: {
          HiveMetaKeys.selectedColorThemeId: 'beige',
        }).read(selectedColorThemeProvider),
        AppColorTheme.warmBeige,
      );
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
