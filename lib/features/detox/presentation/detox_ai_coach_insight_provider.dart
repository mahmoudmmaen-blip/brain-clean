import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/detox_ai_coach_service_provider.dart';
import '../domain/ai_coach/ai_coach_dynamic_context.dart';
import '../domain/ai_coach/ai_coach_pipeline_response.dart';
import '../domain/detox_protocol_state.dart';

part 'detox_ai_coach_insight_provider.g.dart';

/// Alias for the feature-level insights slot (preferred naming).
final detoxAiInsightsProvider = detoxAiCoachInsightProvider;

/// Latest machine-readable AI coaching insight after a detox check-in.
///
/// Updated asynchronously by [DetoxProtocolController] — never blocks habit sync.
@riverpod
class DetoxAiCoachInsight extends _$DetoxAiCoachInsight {
  @override
  Future<AiCoachPipelineResponse?> build() async => null;

  /// Fetches coaching insight for a saved check-in (background-safe).
  Future<void> fetchForCheckIn({
    required DetoxProtocolState detoxState,
    required double bcScore,
    String locale = 'ar',
  }) async {
    publishLoading();
    try {
      final service = ref.read(detoxAiCoachServiceProvider);
      final context = AiCoachDynamicContext(
        userMessage: 'Daily detox check-in saved',
        locale: locale,
        bcScore: bcScore,
        variables: {
          'boredomBefriended': detoxState.boredomBefriended,
          'delayedGratificationCount': detoxState.delayedGratificationCount,
          'bodyActivated': detoxState.bodyActivated,
          'detoxHabitScore': detoxState.detoxHabitScore,
        },
      );
      final result = await service.fetchInsights(context);
      publishInsight(result);
    } catch (error) {
      assert(() {
        debugPrint('DetoxAiCoachInsight: $error');
        return true;
      }());
      publishInsight(null);
    }
  }

  void publishLoading() {
    state = const AsyncValue.loading();
  }

  void publishInsight(AiCoachPipelineResponse? insight) {
    state = AsyncData(insight);
  }

  void clear() {
    state = const AsyncData(null);
  }
}
