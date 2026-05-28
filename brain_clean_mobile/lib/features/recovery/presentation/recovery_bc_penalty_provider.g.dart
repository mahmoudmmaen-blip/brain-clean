// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_bc_penalty_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveryBcPenaltyTotalHash() =>
    r'684f45e568346d3c1a0271e5610cc16db264bbc2';

/// Total BC_score deducted from recovery penalty box entries (−15 each).
///
/// Copied from [recoveryBcPenaltyTotal].
@ProviderFor(recoveryBcPenaltyTotal)
final recoveryBcPenaltyTotalProvider = Provider<double>.internal(
  recoveryBcPenaltyTotal,
  name: r'recoveryBcPenaltyTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recoveryBcPenaltyTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecoveryBcPenaltyTotalRef = ProviderRef<double>;
String _$recoveryDiagnosticPenaltySyncHash() =>
    r'27b182646af642f73550eeb43b282024a2e45b07';

/// Syncs recovery penalties into committed diagnostic snapshots.
///
/// Copied from [RecoveryDiagnosticPenaltySync].
@ProviderFor(RecoveryDiagnosticPenaltySync)
final recoveryDiagnosticPenaltySyncProvider =
    NotifierProvider<RecoveryDiagnosticPenaltySync, void>.internal(
  RecoveryDiagnosticPenaltySync.new,
  name: r'recoveryDiagnosticPenaltySyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recoveryDiagnosticPenaltySyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecoveryDiagnosticPenaltySync = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
