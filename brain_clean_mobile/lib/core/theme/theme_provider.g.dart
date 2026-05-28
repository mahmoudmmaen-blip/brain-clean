// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLightThemeHash() => r'7dde6c5e770cfa530a88bbe52cc98f52e5d28bdb';

/// See also [appLightTheme].
@ProviderFor(appLightTheme)
final appLightThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  appLightTheme,
  name: r'appLightThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLightThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppLightThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$appDarkThemeHash() => r'ca14baf218c2648ac9cfaadab1f424771d6f3cf8';

/// See also [appDarkTheme].
@ProviderFor(appDarkTheme)
final appDarkThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  appDarkTheme,
  name: r'appDarkThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDarkThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDarkThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$appDesignTokensHash() => r'b97bdd5e088520fd196117ea33b4c098072c952d';

/// Brand tokens exposed to widgets without importing constants directly.
///
/// Copied from [appDesignTokens].
@ProviderFor(appDesignTokens)
final appDesignTokensProvider = AutoDisposeProvider<AppDesignTokens>.internal(
  appDesignTokens,
  name: r'appDesignTokensProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDesignTokensHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDesignTokensRef = AutoDisposeProviderRef<AppDesignTokens>;
String _$appThemeModeHash() => r'1d26b36d5512e0ab532eb1e2bd178acd4764631d';

/// User-selected appearance (system / light / dark).
///
/// Copied from [AppThemeMode].
@ProviderFor(AppThemeMode)
final appThemeModeProvider =
    AutoDisposeNotifierProvider<AppThemeMode, ThemeMode>.internal(
  AppThemeMode.new,
  name: r'appThemeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppThemeMode = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
