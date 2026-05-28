import 'package:flutter/material.dart';

import 'app_design_constants.dart';

/// Theme-aware text and surface helpers for light/dark visibility.
extension AppThemeContext on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  Color get textMuted =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.58);

  Color get textSubtle =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.38);

  Color get surfaceMuted =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.12);

  Color get borderMuted => Theme.of(this).dividerColor;

  Color get brandPrimary => isLightTheme
      ? AppDesignConstants.brandGreen
      : Theme.of(this).colorScheme.primary;

  /// Large Arabic question copy — high contrast, generous line height.
  TextStyle get arabicQuestionStyle {
    final onSurface = Theme.of(this).colorScheme.onSurface;
    return AppDesignConstants.cairo(
      fontSize: AppDesignConstants.arabicQuestionFontSize,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: AppDesignConstants.arabicQuestionLineHeight,
    );
  }

  /// Standard Arabic body (interpretations, subtitles).
  TextStyle get arabicBodyStyle {
    final onSurface = Theme.of(this).colorScheme.onSurface;
    return AppDesignConstants.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: onSurface,
      height: AppDesignConstants.arabicBodyLineHeight,
    );
  }

  /// Progress / step labels above questions.
  TextStyle get arabicLabelStyle {
    return AppDesignConstants.cairo(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: textMuted,
      height: 1.4,
      letterSpacing: AppDesignConstants.arabicLabelLetterSpacing,
    );
  }
}
