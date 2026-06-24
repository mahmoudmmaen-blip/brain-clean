// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityOnlineHash() =>
    r'b20414ea80a1a036465b381b2661a9f015fe76da';

/// Lightweight online gate for sync — Supabase configured + authenticated session.
///
/// Does not add a network probe dependency; failed sync calls imply offline.
///
/// Copied from [connectivityOnline].
@ProviderFor(connectivityOnline)
final connectivityOnlineProvider = Provider<bool>.internal(
  connectivityOnline,
  name: r'connectivityOnlineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConnectivityOnlineRef = ProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
