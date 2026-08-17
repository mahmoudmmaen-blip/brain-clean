import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tone of a snack bar, mapped to the design tokens.
enum AppSnackBarTone { neutral, success, error }

Color? _backgroundFor(AppSnackBarTone tone) => switch (tone) {
      AppSnackBarTone.neutral => null,
      AppSnackBarTone.success => AppColors.primary,
      AppSnackBarTone.error => AppColors.danger,
    };

/// Shows a snack bar with the app's tone colors.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarTone tone = AppSnackBarTone.neutral,
  Duration? duration,
  SnackBarBehavior? behavior,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: _backgroundFor(tone),
      duration: duration ?? const Duration(seconds: 4),
      behavior: behavior,
    ),
  );
}

/// Shorthand for a positive-outcome snack bar.
void showSuccessSnackBar(BuildContext context, String message) =>
    showAppSnackBar(context, message, tone: AppSnackBarTone.success);

/// Shorthand for a failure snack bar.
void showErrorSnackBar(
  BuildContext context,
  String message, {
  SnackBarBehavior? behavior,
}) =>
    showAppSnackBar(
      context,
      message,
      tone: AppSnackBarTone.error,
      behavior: behavior,
    );
