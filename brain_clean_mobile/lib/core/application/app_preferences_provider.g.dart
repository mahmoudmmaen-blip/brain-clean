// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isProUserHash() => r'59d4a42b13f52f6e7f25bbac052fb47b75ff9811';

/// Convenience read-only aliases for pro/onboarding gates.
///
/// Copied from [isProUser].
@ProviderFor(isProUser)
final isProUserProvider = AutoDisposeProvider<bool>.internal(
  isProUser,
  name: r'isProUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isProUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsProUserRef = AutoDisposeProviderRef<bool>;
String _$hasSeenOnboardingHash() => r'3e6fb0887fb1225a2e38c93b18d790cfcdf4e631';

/// See also [hasSeenOnboarding].
@ProviderFor(hasSeenOnboarding)
final hasSeenOnboardingProvider = AutoDisposeProvider<bool>.internal(
  hasSeenOnboarding,
  name: r'hasSeenOnboardingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasSeenOnboardingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasSeenOnboardingRef = AutoDisposeProviderRef<bool>;
String _$appPreferencesHash() => r'5073673ee15848091bbd9cddd1c7cd16a8d3bb85';

/// See also [AppPreferences].
@ProviderFor(AppPreferences)
final appPreferencesProvider =
    NotifierProvider<AppPreferences, AppPreferencesState>.internal(
  AppPreferences.new,
  name: r'appPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppPreferences = Notifier<AppPreferencesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
