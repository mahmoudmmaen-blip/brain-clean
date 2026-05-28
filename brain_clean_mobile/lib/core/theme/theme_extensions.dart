import 'package:flutter/material.dart';

/// Theme-aware text and surface helpers for light/dark visibility.
extension AppThemeContext on BuildContext {
  Color get textMuted =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.58);

  Color get textSubtle =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.38);

  Color get surfaceMuted =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.12);

  Color get borderMuted => Theme.of(this).dividerColor;
}
