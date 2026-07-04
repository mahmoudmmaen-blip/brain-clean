// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$entitlementStatusHash() => r'4bc06667b65b12e0b05a916911b2644eab80a3af';

/// Live Pro entitlement — emits `true`/`false` and updates in real time when
/// the user purchases, restores, or the subscription expires.
///
/// Seeds from [Purchases.getCustomerInfo] and then follows
/// [Purchases.addCustomerInfoUpdateListener]. Emits `false` when the SDK is not
/// configured so gates fail closed without touching native code.
///
/// Copied from [entitlementStatus].
@ProviderFor(entitlementStatus)
final entitlementStatusProvider = StreamProvider<bool>.internal(
  entitlementStatus,
  name: r'entitlementStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entitlementStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EntitlementStatusRef = StreamProviderRef<bool>;
String _$proOfferingHash() => r'43216e1b536123da913ac4998140d110f0285a8d';

/// The current ("default") offering, or `null` when unavailable (SDK not
/// configured, offline, or nothing configured in the dashboard).
///
/// Copied from [proOffering].
@ProviderFor(proOffering)
final proOfferingProvider = AutoDisposeFutureProvider<Offering?>.internal(
  proOffering,
  name: r'proOfferingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$proOfferingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProOfferingRef = AutoDisposeFutureProviderRef<Offering?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
