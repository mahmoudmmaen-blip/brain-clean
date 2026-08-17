import 'package:flutter/material.dart';

/// Brain Clean design tokens — Morning Light identity.
abstract final class AppColors {
  static const background = Color(0xFF15130F);
  static const card = Color(0xFF1E1A14);
  static const border = Color(0xFF332C21);
  static const primary = Color(0xFFD97245);
  static const primaryDark = Color(0xFFB8613B);
  static const positive = Color(0xFF5B8266);
  static const textPrimary = Color(0xFFF2EBDE);
  static const textSecondary = Color(0xFFA99A85);
  static const danger = Color(0xFFC2564A);
  static const warning = Color(0xFFD9A24B);
  static const info = Color(0xFF6E93A8);

  // Light-mode counterparts (primary/positive/danger/warning/info shared).
  static const backgroundLight = Color(0xFFFBF8F3);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE5DDCE);
  static const textPrimaryLight = Color(0xFF231F19);
  static const textSecondaryLight = Color(0xFF6B6154);
}
