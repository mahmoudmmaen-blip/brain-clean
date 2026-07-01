// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognitive_test_results_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cognitiveTestResultsHash() =>
    r'618e7571d9be8811af6d321561d92142021ae4ac';

/// Latest cognitive mini-game results — feeds [CognitiveTestScorer] → live BHI.
///
/// Copied from [CognitiveTestResults].
@ProviderFor(CognitiveTestResults)
final cognitiveTestResultsProvider =
    NotifierProvider<CognitiveTestResults, CognitiveTestResultsState>.internal(
  CognitiveTestResults.new,
  name: r'cognitiveTestResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cognitiveTestResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CognitiveTestResults = Notifier<CognitiveTestResultsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
