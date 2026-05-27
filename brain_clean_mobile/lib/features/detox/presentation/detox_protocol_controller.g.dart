// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detox_protocol_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detoxProtocolDataHash() => r'ca009e7c085fbea9c520920f798229b4d9634c08';

/// See also [detoxProtocolData].
@ProviderFor(detoxProtocolData)
final detoxProtocolDataProvider =
    AutoDisposeProvider<DetoxProtocolState>.internal(
  detoxProtocolData,
  name: r'detoxProtocolDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxProtocolDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DetoxProtocolDataRef = AutoDisposeProviderRef<DetoxProtocolState>;
String _$detoxProtocolControllerHash() =>
    r'21f517f318fc6362fda659fe2a99298e08304032';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Core pipeline (blocking)
///
/// ```
/// User Input → DetoxHabitScorer → snake_case Firestore upsert → UI refresh
/// ```
///
/// ## Optional AI pipeline (non-blocking)
///
/// ```
/// After successful sync → unawaited DetoxAiCoachService → detoxAiCoachInsightProvider
/// ```
///
/// AI failures never affect habit state or Firestore sync.
///
/// Copied from [DetoxProtocolController].
@ProviderFor(DetoxProtocolController)
final detoxProtocolControllerProvider = AutoDisposeAsyncNotifierProvider<
    DetoxProtocolController, DetoxProtocolState>.internal(
  DetoxProtocolController.new,
  name: r'detoxProtocolControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxProtocolControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DetoxProtocolController
    = AutoDisposeAsyncNotifier<DetoxProtocolState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
