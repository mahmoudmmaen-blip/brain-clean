import 'package:flutter/material.dart';

/// Pro-gated UI accent themes. [classicGreen] is the default free-tier theme.
enum AppColorTheme {
  classicGreen('classicGreen', Color(0xFF1D9E75), Color(0xFF0F7A5A)),
  deepBlue('deepBlue', Color(0xFF3B82F6), Color(0xFF2563EB)),
  royalPurple('royalPurple', Color(0xFF8B5CF6), Color(0xFF7C3AED)),
  sunsetOrange('sunsetOrange', Color(0xFFF59E0B), Color(0xFFD97706));

  const AppColorTheme(this.id, this.primary, this.primaryDark);

  final String id;
  final Color primary;
  final Color primaryDark;

  /// Only [classicGreen] is available without a Pro subscription.
  bool get requiresPro => this != AppColorTheme.classicGreen;
}
