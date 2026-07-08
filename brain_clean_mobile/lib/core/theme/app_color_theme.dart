import 'package:flutter/material.dart';

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

  Brightness get brightness =>
      this == AppColorTheme.daylight ? Brightness.light : Brightness.dark;

  Color get accent => switch (this) {
    AppColorTheme.midnight => const Color(0xFF27E0B0),
    AppColorTheme.aurora => const Color(0xFFA78BFA),
    AppColorTheme.pine => const Color(0xFF34D399),
    AppColorTheme.solar => const Color(0xFFFBBF24),
    AppColorTheme.slate => const Color(0xFF60A5FA),
    AppColorTheme.daylight => const Color(0xFF0FA988),
  };

  Color get background => switch (this) {
    AppColorTheme.midnight => const Color(0xFF070B14),
    AppColorTheme.aurora => const Color(0xFF12101F),
    AppColorTheme.pine => const Color(0xFF0A1410),
    AppColorTheme.solar => const Color(0xFF15110A),
    AppColorTheme.slate => const Color(0xFF0E1218),
    AppColorTheme.daylight => const Color(0xFFF6F8FB),
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
