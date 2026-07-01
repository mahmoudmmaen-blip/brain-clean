// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'displayed_xp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverTotalXpHash() => r'1bb6f6ed7b7019a4aa167a07f98b0ed4c1417fbd';

/// Cached authoritative server XP total (written after successful [verify-xp]).
///
/// Copied from [serverTotalXp].
@ProviderFor(serverTotalXp)
final serverTotalXpProvider = Provider<int?>.internal(
  serverTotalXp,
  name: r'serverTotalXpProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverTotalXpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ServerTotalXpRef = ProviderRef<int?>;
String _$displayedXpHash() => r'48dbe31194f3dd9dee9d1fdcf35bca8cd653f37f';

/// Displayed XP: prefer [serverTotalXp] when synced online, else local ledger sum.
///
/// Local XP is optimistic; server total wins for shared/competitive displays.
///
/// Copied from [displayedXp].
@ProviderFor(displayedXp)
final displayedXpProvider = FutureProvider<int>.internal(
  displayedXp,
  name: r'displayedXpProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$displayedXpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DisplayedXpRef = FutureProviderRef<int>;
String _$displayedXpSyncHash() => r'fa4f80df4395040b0757d34431e11afa4cf62729';

/// Sync-friendly displayed XP for widgets.
///
/// Copied from [displayedXpSync].
@ProviderFor(displayedXpSync)
final displayedXpSyncProvider = AutoDisposeProvider<int>.internal(
  displayedXpSync,
  name: r'displayedXpSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$displayedXpSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DisplayedXpSyncRef = AutoDisposeProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
