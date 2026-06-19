// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detox_protocol_scoring_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detoxHabitScoreHash() => r'c43757deaf97f058c165e68dba3cde8251485b02';

/// Live detox habit score (0–100) — recomputes when check-ins change.
///
/// Copied from [detoxHabitScore].
@ProviderFor(detoxHabitScore)
final detoxHabitScoreProvider = AutoDisposeProvider<double>.internal(
  detoxHabitScore,
  name: r'detoxHabitScoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxHabitScoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DetoxHabitScoreRef = AutoDisposeProviderRef<double>;
String _$detoxHabitSubScoresHash() =>
    r'c1b3d235bcde072dbef4a4aee7dd7892af24766c';

/// Sub-component score breakdown for the 7-Day Dopamine Detox card.
///
/// Copied from [detoxHabitSubScores].
@ProviderFor(detoxHabitSubScores)
final detoxHabitSubScoresProvider =
    AutoDisposeProvider<DetoxHabitSubScores>.internal(
  detoxHabitSubScores,
  name: r'detoxHabitSubScoresProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxHabitSubScoresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DetoxHabitSubScoresRef = AutoDisposeProviderRef<DetoxHabitSubScores>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
