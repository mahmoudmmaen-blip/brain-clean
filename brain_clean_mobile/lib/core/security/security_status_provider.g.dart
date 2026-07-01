// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceCompromisedHash() => r'f6f0d3f68cc4a526ad3885580045b6160625372f';

/// Exposes [RootDetector.isCompromised] for banners and cloud-sync policy.
///
/// Copied from [deviceCompromised].
@ProviderFor(deviceCompromised)
final deviceCompromisedProvider = Provider<bool>.internal(
  deviceCompromised,
  name: r'deviceCompromisedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceCompromisedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceCompromisedRef = ProviderRef<bool>;
String _$biometricSessionHash() => r'af4318bf0e05ab9b4c40d330b92291375c4da19c';

/// Whether the user passed biometric gate this session.
///
/// Copied from [BiometricSession].
@ProviderFor(BiometricSession)
final biometricSessionProvider =
    NotifierProvider<BiometricSession, bool>.internal(
  BiometricSession.new,
  name: r'biometricSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricSession = Notifier<bool>;
String _$biometricLockSettingsHash() =>
    r'fe140fc3a0a78a2c4a1e32903a907a7828f1566a';

/// Sync mirror of [SecureKeyStore.isBiometricLockEnabled] for GoRouter.
///
/// Copied from [BiometricLockSettings].
@ProviderFor(BiometricLockSettings)
final biometricLockSettingsProvider =
    NotifierProvider<BiometricLockSettings, bool>.internal(
  BiometricLockSettings.new,
  name: r'biometricLockSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricLockSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricLockSettings = Notifier<bool>;
String _$biometricAuthControllerHash() =>
    r'974e88f709b5ef34ca81de607a898d038ccae57c';

/// Runs biometric auth and updates [biometricSessionProvider].
///
/// Copied from [BiometricAuthController].
@ProviderFor(BiometricAuthController)
final biometricAuthControllerProvider =
    AsyncNotifierProvider<BiometricAuthController, bool>.internal(
  BiometricAuthController.new,
  name: r'biometricAuthControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$biometricAuthControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BiometricAuthController = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
