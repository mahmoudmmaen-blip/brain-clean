import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_meta_keys.dart';
import '../data/app_meta_box_provider.dart';
import '../../features/pro/application/subscription_service_provider.dart';
import 'app_color_theme.dart';

/// Maps persisted theme ids (including legacy 6-theme names) to the 2-mode enum.
AppColorTheme appColorThemeFromStoredName(String? stored) {
  switch (stored) {
    case 'light':
    case 'daylight':
      return AppColorTheme.light;
    case 'dark':
    case 'midnight':
    case 'aurora':
    case 'pine':
    case 'solar':
    case 'slate':
      return AppColorTheme.dark;
    default:
      // Unknown / null → dark (Morning Light default).
      return AppColorTheme.dark;
  }
}

class SelectedColorThemeNotifier extends Notifier<AppColorTheme> {
  @override
  AppColorTheme build() {
    try {
      final box = ref.watch(appMetaBoxProvider);
      final stored = box.get(HiveMetaKeys.selectedColorThemeId) as String?;
      return appColorThemeFromStoredName(stored);
    } catch (_) {
      return AppColorTheme.dark;
    }
  }

  Future<void> select(AppColorTheme theme) async {
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(HiveMetaKeys.selectedColorThemeId, theme.name);
    } catch (_) {
      // Hive unavailable (e.g. widget tests) — fall back to in-memory state.
    }
    state = theme;
  }
}

final selectedColorThemeProvider =
    NotifierProvider<SelectedColorThemeNotifier, AppColorTheme>(
  SelectedColorThemeNotifier.new,
);

/// The color theme actually applied — falls back to [AppColorTheme.dark]
/// if the persisted selection is Pro-only and entitlement has lapsed.
final effectiveColorThemeProvider = Provider<AppColorTheme>((ref) {
  final selected = ref.watch(selectedColorThemeProvider);
  if (selected.isPro && !ref.watch(isProUserProvider)) {
    return AppColorTheme.dark;
  }
  return selected;
});
