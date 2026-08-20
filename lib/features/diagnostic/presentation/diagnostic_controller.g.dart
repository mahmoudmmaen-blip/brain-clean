// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagnosticLiveModelHash() =>
    r'b2466fc47160d323a0b256371dd97326221c8d51';

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
    r'a1a41c33a147b500071855f71a06351802331715';

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
