// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_in_progress_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticInProgressSessionHash() =>
    r'8c19a3ce8680e7bed6ede726cdc4bf660aa4fca0';

/// Unified [DiagnosticSession] view for the active diagnostic flow.
///
/// Merges BHI snapshot, slider metrics, and questionnaire state so UI layers
/// consume one model instead of multiple providers.
///
/// Copied from [diagnosticInProgressSession].
@ProviderFor(diagnosticInProgressSession)
final diagnosticInProgressSessionProvider =
    AutoDisposeProvider<DiagnosticSession>.internal(
  diagnosticInProgressSession,
  name: r'diagnosticInProgressSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticInProgressSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiagnosticInProgressSessionRef
    = AutoDisposeProviderRef<DiagnosticSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
