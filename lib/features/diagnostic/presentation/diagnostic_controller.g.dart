// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticLiveModelHash() =>
    r'15af5cb4a02d506b548e3adaf54c26258126e5a6';

/// Synchronous live BHI projection — sliders + detox recomputed on every watch.
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

typedef DiagnosticLiveModelRef = ProviderRef<DiagnosticModel>;
String _$diagnosticLiveSessionHash() =>
    r'868f14593ee23605f89e73a2ef5be8f197bc6fd9';

/// Reactive live [DiagnosticSession] for diagnostic UI and breakdown widgets.
///
/// Rebuilds when metrics (async hydrate), questionnaire, live model, or penalties change.
///
/// Copied from [diagnosticLiveSession].
@ProviderFor(diagnosticLiveSession)
final diagnosticLiveSessionProvider = Provider<DiagnosticSession>.internal(
  diagnosticLiveSession,
  name: r'diagnosticLiveSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diagnosticLiveSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DiagnosticLiveSessionRef = ProviderRef<DiagnosticSession>;
String _$diagnosticControllerHash() =>
    r'973a25f1e2902c6d2a1956e9e8142d26ee74449d';

/// Slider metrics, live model, and session packaging — single orchestrator.
///
/// - **Async**: [build] hydrates slider metrics from Hive (cold start).
/// - **Sync**: [computeLiveModel] / [buildLiveSession] project immediately on UI edits.
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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
