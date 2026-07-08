// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$xpSyncApiHash() => r'9681c4db93263ec3d48f59f55227974a546b2416';

/// See also [xpSyncApi].
@ProviderFor(xpSyncApi)
final xpSyncApiProvider = Provider<XpSyncApi>.internal(
  xpSyncApi,
  name: r'xpSyncApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$xpSyncApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef XpSyncApiRef = ProviderRef<XpSyncApi>;
String _$xpSyncServiceHash() => r'3bafda42f06bd852736f26ad1b721b49dfeda192';

/// Pushes [XpSyncState.pendingVerify] entries to [verify-xp] and reconciles totals.
///
/// Offline-first: failures leave entries pending; never blocks the user.
///
/// Copied from [XpSyncService].
@ProviderFor(XpSyncService)
final xpSyncServiceProvider =
    AsyncNotifierProvider<XpSyncService, void>.internal(
  XpSyncService.new,
  name: r'xpSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$xpSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$XpSyncService = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
