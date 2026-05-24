import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Score-tier colors shared across diagnostic and dashboard UI.
abstract final class BcScoreColors {
  static Color forScore(double score) {
    if (score <= 30) return const Color(0xFFEF4444);
    if (score <= 60) return AppTheme.gold;
    if (score <= 85) return AppTheme.success;
    return const Color(0xFF0F6E56);
  }
}
