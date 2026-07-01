// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verified_xp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$verifiedTotalXpSyncHash() =>
    r'99ce08d18303f625342980f9d6678c891d0caf69';

/// Sync-friendly XP for widgets — defaults to 0 while loading.
///
/// Copied from [verifiedTotalXpSync].
@ProviderFor(verifiedTotalXpSync)
final verifiedTotalXpSyncProvider = AutoDisposeProvider<int>.internal(
  verifiedTotalXpSync,
  name: r'verifiedTotalXpSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verifiedTotalXpSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VerifiedTotalXpSyncRef = AutoDisposeProviderRef<int>;
String _$verifiedTotalXpHash() => r'6f1fa6240167c05ae1b4dad212642d5399feb619';

/// Verified XP total — derived sum over the signed append-only ledger.
///
/// Copied from [VerifiedTotalXp].
@ProviderFor(VerifiedTotalXp)
final verifiedTotalXpProvider =
    AsyncNotifierProvider<VerifiedTotalXp, int>.internal(
  VerifiedTotalXp.new,
  name: r'verifiedTotalXpProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verifiedTotalXpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VerifiedTotalXp = AsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
