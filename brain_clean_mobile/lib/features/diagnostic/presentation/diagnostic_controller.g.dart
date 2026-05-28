// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticLiveModelHash() =>
    r'7a05ef9607981721ebaf6f18170b5a5db11f9fc7';

/// Live four-pillar model — recomputes when sliders or detox habits change.
///
/// Copied from [diagnosticLiveModel].
@ProviderFor(diagnosticLiveModel)
final diagnosticLiveModelProvider = Provider<DiagnosticModel>.internal(
  diagnosticLiveModel,
  name: r'diagnosticLiveModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticLiveModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiagnosticLiveModelRef = ProviderRef<DiagnosticModel>;
String _$diagnosticControllerHash() =>
    r'f927437b8fc3daec1c57b404e6bb7d75ade8538d';

/// Slider metrics, BHI composition, and session packaging (single orchestrator).
///
/// Persistence: drafts written on every slider change; committed sessions flow
/// through [BcScoreSession.commit] → [DiagnosticLocalRepository].
///
/// Copied from [DiagnosticController].
@ProviderFor(DiagnosticController)
final diagnosticControllerProvider =
    AsyncNotifierProvider<DiagnosticController, DiagnosticMetrics>.internal(
  DiagnosticController.new,
  name: r'diagnosticControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiagnosticController = AsyncNotifier<DiagnosticMetrics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
