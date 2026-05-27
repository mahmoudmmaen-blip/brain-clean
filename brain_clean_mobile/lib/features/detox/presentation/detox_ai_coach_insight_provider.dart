import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/detox_ai_coach_service_provider.dart';
import '../domain/ai_coach/ai_coach_dynamic_context.dart';
import '../domain/ai_coach/ai_coach_pipeline_response.dart';
import '../domain/detox_protocol_state.dart';

part 'detox_ai_coach_insight_provider.g.dart';

/// Latest machine-readable AI coaching insight after a detox check-in.
@riverpod
class DetoxAiCoachInsight extends _$DetoxAiCoachInsight {
  @override
  Future<AiCoachPipelineResponse?> build() async => null;

  /// Fetches coaching insight for a saved check-in (optional UX enhancement).
  Future<void> fetchForCheckIn({
    required DetoxProtocolState detoxState,
    required double bcScore,
    String locale = 'ar',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
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
      return service.fetchCoachingInsight(context);
    });
  }

  void clear() {
    state = const AsyncData(null);
  }
}
