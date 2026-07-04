// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isProUserHash() => r'0420b2c10324064667cc7bc40da3e59bc3d62869';

/// Reactive Pro entitlement, derived from [entitlementStatusProvider].
///
/// Defaults to `false` until RevenueCat resolves the first customer info, and
/// updates automatically via the customer-info listener. Used by
/// [navigateWithProGate] and every other Pro gate in the app.
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
