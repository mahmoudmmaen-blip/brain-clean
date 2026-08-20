// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'1dbc4e7907afc7c9cafdc40da9c6bd851e2e3114';

/// See also [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider = Provider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionServiceRef = ProviderRef<SubscriptionService>;
String _$isProUserHash() => r'aa1d6ad7c6d5b3448b06b6252d1c32f4f309c62f';

/// Reactive Premium entitlement from the selected [SubscriptionService].
///
/// Production authority is RevenueCat / store-verified mirror — never Hive-only
/// when the production adapters are selected.
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
