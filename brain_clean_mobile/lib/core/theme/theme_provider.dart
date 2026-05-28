import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_theme.dart';

part 'theme_provider.g.dart';

/// User-selected appearance (system / light / dark).
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;

  void useSystem() => state = ThemeMode.system;

  void useLight() => state = ThemeMode.light;

  void useDark() => state = ThemeMode.dark;

  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}

@riverpod
ThemeData appLightTheme(AppLightThemeRef ref) => AppTheme.light;

@riverpod
ThemeData appDarkTheme(AppDarkThemeRef ref) => AppTheme.dark;
