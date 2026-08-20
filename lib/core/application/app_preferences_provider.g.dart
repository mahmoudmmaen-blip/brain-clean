// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasSeenOnboardingHash() => r'3e6fb0887fb1225a2e38c93b18d790cfcdf4e631';

/// Convenience read-only alias for onboarding gates.
///
/// See `isProUserProvider` in `subscription_service_provider.dart` for the
/// Pro entitlement equivalent (backed by [SubscriptionService]).
///
/// Copied from [hasSeenOnboarding].
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
String _$appPreferencesHash() => r'dc1fa9654a5f893e1c28021f5b71baf2b03dd0cd';

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
