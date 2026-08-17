import 'package:flutter/material.dart';

/// Selectable appearance modes — Morning Light dark / light only.
enum AppColorTheme { dark, light }

extension AppColorThemeX on AppColorTheme {
  /// Both modes are free; Pro-gating plumbing remains elsewhere.
  bool get isPro => false;

  Brightness get brightness => switch (this) {
        AppColorTheme.dark => Brightness.dark,
        AppColorTheme.light => Brightness.light,
      };
}
