import 'package:flutter/material.dart';

/// Selectable appearance modes — Dark / Light / AMOLED.
enum AppColorTheme { dark, light, amoled }

extension AppColorThemeX on AppColorTheme {
  /// All three modes are free; Pro-gating plumbing remains elsewhere.
  bool get isPro => false;

  Brightness get brightness => switch (this) {
        AppColorTheme.dark => Brightness.dark,
        AppColorTheme.light => Brightness.light,
        AppColorTheme.amoled => Brightness.dark,
      };
}
