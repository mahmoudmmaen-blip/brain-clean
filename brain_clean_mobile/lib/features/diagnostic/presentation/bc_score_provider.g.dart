// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bc_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bcScoreLiveHash() => r'a9f6727781b6811613e98d2105f2a897156d8e49';

/// Recomputes BHI pillars whenever sliders or detox check-ins change.
///
/// Delegates to [diagnosticLiveModelProvider] — authoritative path is
/// [DiagnosticSessionComposer.resolveLiveModel].
///
/// Copied from [bcScoreLive].
@ProviderFor(bcScoreLive)
final bcScoreLiveProvider = AutoDisposeProvider<DiagnosticModel>.internal(
  bcScoreLive,
  name: r'bcScoreLiveProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bcScoreLiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BcScoreLiveRef = AutoDisposeProviderRef<DiagnosticModel>;
String _$bcScoreSessionHash() => r'923a04c3689b9ec1b8493d530eb55c0e4fecb541';

/// Snapshot saved on diagnostic submit — shown on dashboard.
///
/// Copied from [BcScoreSession].
@ProviderFor(BcScoreSession)
final bcScoreSessionProvider =
    AutoDisposeNotifierProvider<BcScoreSession, DiagnosticSession?>.internal(
  BcScoreSession.new,
  name: r'bcScoreSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bcScoreSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BcScoreSession = AutoDisposeNotifier<DiagnosticSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
