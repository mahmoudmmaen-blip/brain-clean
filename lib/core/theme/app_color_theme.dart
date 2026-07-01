import 'package:flutter/material.dart';

/// Selectable app color themes — 2 free, 4 Pro-gated.
enum AppColorTheme { midnight, aurora, pine, solar, slate, daylight }

extension AppColorThemeX on AppColorTheme {
  bool get isPro => switch (this) {
        AppColorTheme.midnight => false,
        AppColorTheme.aurora => false,
        AppColorTheme.pine => true,
        AppColorTheme.solar => true,
        AppColorTheme.slate => true,
        AppColorTheme.daylight => true,
      };

  /// Only [daylight] is a light theme — all other themes force dark mode.
  Brightness get brightness =>
      this == AppColorTheme.daylight ? Brightness.light : Brightness.dark;

  Color get accent => switch (this) {
        AppColorTheme.midnight => const Color(0xFF6366F1),
        AppColorTheme.aurora => const Color(0xFF22D3EE),
        AppColorTheme.pine => const Color(0xFF22C55E),
        AppColorTheme.solar => const Color(0xFFF59E0B),
        AppColorTheme.slate => const Color(0xFF94A3B8),
        AppColorTheme.daylight => const Color(0xFF4F46E5),
      };

  Color get background => switch (this) {
        AppColorTheme.midnight => const Color(0xFF07090F),
        AppColorTheme.aurora => const Color(0xFF071019),
        AppColorTheme.pine => const Color(0xFF06120D),
        AppColorTheme.solar => const Color(0xFF140D06),
        AppColorTheme.slate => const Color(0xFF0F1115),
        AppColorTheme.daylight => const Color(0xFFF8FAFC),
      };

  Color get surface => switch (this) {
        AppColorTheme.midnight => const Color(0xFF131920),
        AppColorTheme.aurora => const Color(0xFF112030),
        AppColorTheme.pine => const Color(0xFF102019),
        AppColorTheme.solar => const Color(0xFF221608),
        AppColorTheme.slate => const Color(0xFF1A1D23),
        AppColorTheme.daylight => const Color(0xFFFFFFFF),
      };
}