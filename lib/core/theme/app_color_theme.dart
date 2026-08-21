import 'package:flutter/material.dart';

/// Selectable appearance modes — Dark / Light / AMOLED / Pure White / Warm Beige.
enum AppColorTheme { dark, light, amoled, pureWhite, warmBeige }

extension AppColorThemeX on AppColorTheme {
  /// All five modes are free; Pro-gating plumbing remains elsewhere.
  bool get isPro => false;

  Brightness get brightness => switch (this) {
        AppColorTheme.dark => Brightness.dark,
        AppColorTheme.light => Brightness.light,
        AppColorTheme.amoled => Brightness.dark,
        AppColorTheme.pureWhite => Brightness.light,
        AppColorTheme.warmBeige => Brightness.light,
      };
}
