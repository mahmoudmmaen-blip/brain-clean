import 'package:brain_clean_mobile/core/constants/hive_meta_keys.dart';
import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_color_theme.dart';
import 'package:brain_clean_mobile/core/theme/app_color_theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hive_test_fixtures.dart';

ProviderContainer _container([Map<String, dynamic>? seed]) {
  final container = ProviderContainer(
    overrides: [appMetaBoxProvider.overrideWithValue(InMemoryHiveBox(seed))],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AppColorThemeNotifier', () {
    test('defaults to classicGreen when no key stored', () {
      expect(
        _container().read(appColorThemeProvider),
        AppColorTheme.classicGreen,
      );
    });

    test('restores persisted theme from Hive on build', () {
      final c = _container({
        HiveMetaKeys.selectedColorThemeId: AppColorTheme.deepBlue.id,
      });
      expect(c.read(appColorThemeProvider), AppColorTheme.deepBlue);
    });

    test('pro user can switch to a pro theme', () async {
      final c = _container();
      await c
          .read(appColorThemeProvider.notifier)
          .setTheme(AppColorTheme.royalPurple, isPro: true);
      expect(c.read(appColorThemeProvider), AppColorTheme.royalPurple);
    });

    test('free user cannot switch to a pro theme — stays on classicGreen',
        () async {
      final c = _container();
      await c
          .read(appColorThemeProvider.notifier)
          .setTheme(AppColorTheme.deepBlue, isPro: false);
      expect(c.read(appColorThemeProvider), AppColorTheme.classicGreen);
    });

    test('free user can keep classicGreen', () async {
      final c = _container();
      await c
          .read(appColorThemeProvider.notifier)
          .setTheme(AppColorTheme.classicGreen, isPro: false);
      expect(c.read(appColorThemeProvider), AppColorTheme.classicGreen);
    });
  });
}
