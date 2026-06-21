// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detox_ai_coach_insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detoxAiCoachInsightHash() =>
    r'494dd77723a376fde89118ede82ac28a130cc80c';

/// Latest machine-readable AI coaching insight after a detox check-in.
///
/// Updated asynchronously by [DetoxProtocolController] — never blocks habit sync.
///
/// Copied from [DetoxAiCoachInsight].
@ProviderFor(DetoxAiCoachInsight)
final detoxAiCoachInsightProvider = AutoDisposeAsyncNotifierProvider<
    DetoxAiCoachInsight, AiCoachPipelineResponse?>.internal(
  DetoxAiCoachInsight.new,
  name: r'detoxAiCoachInsightProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detoxAiCoachInsightHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DetoxAiCoachInsight
    = AutoDisposeAsyncNotifier<AiCoachPipelineResponse?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
