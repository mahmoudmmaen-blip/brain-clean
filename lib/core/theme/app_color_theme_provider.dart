import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_meta_keys.dart';
import '../data/app_meta_box_provider.dart';
import 'app_color_theme.dart';

final appColorThemeProvider =
    NotifierProvider<AppColorThemeNotifier, AppColorTheme>(
  AppColorThemeNotifier.new,
);

class AppColorThemeNotifier extends Notifier<AppColorTheme> {
  @override
  AppColorTheme build() {
    try {
      final box = ref.watch(appMetaBoxProvider);
      final id = box.get(
        HiveMetaKeys.selectedColorThemeId,
        defaultValue: AppColorTheme.classicGreen.id,
      ) as String;
      return AppColorTheme.values.firstWhere(
        (t) => t.id == id,
        orElse: () => AppColorTheme.classicGreen,
      );
    } catch (_) {
      return AppColorTheme.classicGreen;
    }
  }

  /// Sets [theme] for Pro users only. No-op for free users selecting a Pro theme.
  Future<void> setTheme(AppColorTheme theme, {required bool isPro}) async {
    if (theme.requiresPro && !isPro) return;
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(HiveMetaKeys.selectedColorThemeId, theme.id);
      ref.invalidateSelf();
    } catch (_) {
      state = theme;
    }
  }
}
