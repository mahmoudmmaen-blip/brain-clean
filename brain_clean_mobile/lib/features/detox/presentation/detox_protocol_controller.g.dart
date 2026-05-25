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
    r'ad630ab0abb550d3831359ed27eb3c3c4a48b654';

/// Orchestrates the 7-Day Dopamine Detox protocol for Brain Clean.
///
/// **Local check-ins → scoring → remote sync**
///
/// 1. Accepts daily habit toggles ([DailyCheckInInput]).
/// 2. Recalculates the habits component through [DetoxHabitScorer] before
///    committing local state.
/// 3. Persists to Supabase using Firestore-compatible **snake_case** keys
///    (`boredom_befriended`, `delayed_gratification_count`, `body_activated`)
///    via [DetoxProtocolRepository.upsert].
/// 4. Hydrates from remote on startup so Firestore data overrides stale cache.
/// 5. Invalidates [bcScoreLiveProvider] after every successful local or remote
///    update so BC_score reflects new habit metrics immediately.
///
/// Sync lifecycle is exposed as [AsyncValue] (`loading` / `error` / `data`).
///
/// Copied from [DetoxProtocolController].
@ProviderFor(DetoxProtocolController)
final detoxProtocolControllerProvider = AutoDisposeNotifierProvider<
    DetoxProtocolController, AsyncValue<DetoxProtocolState>>.internal(
  DetoxProtocolController.new,
  name: r'detoxProtocolControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxProtocolControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DetoxProtocolController
    = AutoDisposeNotifier<AsyncValue<DetoxProtocolState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
