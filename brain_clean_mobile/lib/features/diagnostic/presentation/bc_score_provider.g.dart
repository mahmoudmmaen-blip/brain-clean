// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bc_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bcScoreLiveHash() => r'bf0e531862f20c385f3c2dd407c5248e1dd16c06';

/// Recomputes BHI pillars whenever sliders or detox check-ins change.
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BcScoreLiveRef = AutoDisposeProviderRef<DiagnosticModel>;
String _$bcScoreSessionHash() => r'7d78c5754a66e2176b5b5e2d269387e4ec0b3be9';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
