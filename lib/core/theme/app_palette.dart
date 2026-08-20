import 'package:flutter/material.dart';

import 'app_color_theme.dart';
import 'app_colors.dart';

/// Active semantic palette installed on [ThemeData] via [LocaleTheme].
///
/// Prefer [AppColors.of] in widgets so theme switches apply immediately.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.navBar,
    required this.card,
    required this.cardSecondary,
    required this.cardElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.ringTrack,
    required this.heroGradientTop,
    required this.heroGradientBottom,
    required this.primaryDim,
  });

  final Color background;
  final Color navBar;
  final Color card;
  final Color cardSecondary;
  final Color cardElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color ringTrack;
  final Color heroGradientTop;
  final Color heroGradientBottom;
  final Color primaryDim;

  static const dark = AppPalette(
    background: AppColors.background,
    navBar: AppColors.navBar,
    card: AppColors.card,
    cardSecondary: AppColors.cardSecondary,
    cardElevated: AppColors.cardElevated,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    ringTrack: AppColors.ringTrack,
    heroGradientTop: AppColors.heroGradientTop,
    heroGradientBottom: AppColors.heroGradientBottom,
    primaryDim: AppColors.primaryDim,
  );

  static const light = AppPalette(
    background: AppColors.backgroundLight,
    navBar: AppColors.navBarLight,
    card: AppColors.cardLight,
    cardSecondary: AppColors.cardSecondaryLight,
    cardElevated: AppColors.cardElevatedLight,
    border: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    ringTrack: AppColors.ringTrackLight,
    heroGradientTop: AppColors.heroGradientTopLight,
    heroGradientBottom: AppColors.heroGradientBottomLight,
    primaryDim: AppColors.primaryDimLight,
  );

  static const amoled = AppPalette(
    background: AppColors.backgroundAmoled,
    navBar: AppColors.backgroundAmoled,
    card: AppColors.cardAmoled,
    cardSecondary: AppColors.cardSecondaryAmoled,
    cardElevated: AppColors.cardSecondaryAmoled,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    ringTrack: AppColors.ringTrack,
    heroGradientTop: AppColors.backgroundAmoled,
    heroGradientBottom: AppColors.backgroundAmoled,
    primaryDim: AppColors.primaryDim,
  );

  factory AppPalette.forTheme(AppColorTheme theme) => switch (theme) {
        AppColorTheme.dark => dark,
        AppColorTheme.light => light,
        AppColorTheme.amoled => amoled,
      };

  @override
  AppPalette copyWith({
    Color? background,
    Color? navBar,
    Color? card,
    Color? cardSecondary,
    Color? cardElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? ringTrack,
    Color? heroGradientTop,
    Color? heroGradientBottom,
    Color? primaryDim,
  }) {
    return AppPalette(
      background: background ?? this.background,
      navBar: navBar ?? this.navBar,
      card: card ?? this.card,
      cardSecondary: cardSecondary ?? this.cardSecondary,
      cardElevated: cardElevated ?? this.cardElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      ringTrack: ringTrack ?? this.ringTrack,
      heroGradientTop: heroGradientTop ?? this.heroGradientTop,
      heroGradientBottom: heroGradientBottom ?? this.heroGradientBottom,
      primaryDim: primaryDim ?? this.primaryDim,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardSecondary: Color.lerp(cardSecondary, other.cardSecondary, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      heroGradientTop: Color.lerp(heroGradientTop, other.heroGradientTop, t)!,
      heroGradientBottom:
          Color.lerp(heroGradientBottom, other.heroGradientBottom, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
    );
  }
}
