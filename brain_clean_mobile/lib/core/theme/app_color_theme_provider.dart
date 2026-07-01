import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_meta_keys.dart';
import '../data/app_meta_box_provider.dart';
import '../../features/pro/application/subscription_service_provider.dart';
import 'app_color_theme.dart';

class SelectedColorThemeNotifier extends Notifier<AppColorTheme> {
  @override
  AppColorTheme build() {
    try {
      final box = ref.watch(appMetaBoxProvider);
      final stored = box.get(HiveMetaKeys.selectedColorThemeId) as String?;
      return AppColorTheme.values.asNameMap()[stored] ?? AppColorTheme.midnight;
    } catch (_) {
      return AppColorTheme.midnight;
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

/// The color theme actually applied — falls back to [AppColorTheme.midnight]
/// if the persisted selection is Pro-only and entitlement has lapsed.
final effectiveColorThemeProvider = Provider<AppColorTheme>((ref) {
  final selected = ref.watch(selectedColorThemeProvider);
  if (selected.isPro && !ref.watch(isProUserProvider)) {
    return AppColorTheme.midnight;
  }
  return selected;
});