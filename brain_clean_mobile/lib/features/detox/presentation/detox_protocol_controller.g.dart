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
    r'ece63e0b78bd99fefc1c4a7290ae54573830d596';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// ## Lifecycle
///
/// 1. **Receive** — UI submits partial daily metrics via [DailyCheckInInput].
/// 2. **Score** — [DetoxProtocolState.fromDailyCheckIn] merges inputs, clamps
///    values, and invokes [DetoxHabitScorer] to recalculate
///    [DetoxProtocolState.detoxHabitScore] *before* any state commit.
/// 3. **Commit local** — Optimistic [AsyncValue.data] so widgets and
///    [bcScoreLiveProvider] (via [detoxProtocolDataProvider]) refresh
///    immediately.
/// 4. **Sync remote** — Maps scored state to [DiagnosticModelJsonKeys]
///    snake_case fields (`boredom_befriended`, `delayed_gratification_count`,
///    `body_activated`) through [DetoxProtocolState.toFirestoreHabitPayload]
///    and performs an atomic upsert via [DetoxProtocolRepository.upsertSnakeCasePayload].
///
/// ## Local ↔ remote consistency
///
/// - **Startup:** [build] hydrates from Firestore; remote values override cache.
/// - **Write path:** Every check-in writes the same snake_case keys the
///   [DiagnosticModel] uses, keeping backend and BHI scoring aligned.
/// - **Error path:** Failed upserts preserve optimistic local data via
///   [AsyncValue.copyWithPrevious] so the user never loses check-in progress.
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
