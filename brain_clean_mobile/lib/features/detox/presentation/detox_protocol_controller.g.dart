// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detox_protocol_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detoxProtocolDataHash() => r'ca009e7c085fbea9c520920f798229b4d9634c08';

/// Convenience accessor for habit data when sync [AsyncValue] is in error/loading.
///
/// Copied from [detoxProtocolData].
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
    r'10011d9ef0bd55d7e33ee909bfe138aa097ce1c1';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Data flow
///
/// ```
/// User Input (DailyCheckInInput)
///   → DetoxHabitScorer (via DetoxProtocolState.fromDailyCheckIn)
///   → Repository Transformation Layer (snake_case conversion)
///   → Firestore Write
///   → BC_score Update (bcScoreLiveProvider via detoxProtocolDataProvider)
/// ```
///
/// ## Transformation Layer
///
/// The controller never writes camelCase keys to Firestore. After local scoring,
/// [DetoxProtocolRepository.transformLocalMetricsToFirestorePayload] acts as
/// the final gatekeeper — converting Dart field names to `boredom_befriended`,
/// `delayed_gratification_count`, and `body_activated` before any remote upsert.
///
/// ## Remote data handling (prevents stale state)
///
/// - **Startup:** [build] hydrates from Firestore; remote snake_case values
///   override any stale local cache.
/// - **Write path:** [processDailyCheckIn] scores locally, upserts validated
///   snake_case payload, then re-fetches from server to reconcile.
/// - **Error path:** Failed upserts preserve optimistic local data via
///   [AsyncValue.copyWithPrevious] so check-in progress is never lost.
///
/// Implemented as an [AsyncNotifier] — UI observes `loading → data | error`.
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
