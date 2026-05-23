import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_metrics_mapper.dart';
import 'bc_score_provider.dart';

part 'diagnostic_controller.g.dart';

@riverpod
class DiagnosticController extends _$DiagnosticController {
  @override
  DiagnosticMetrics build() => const DiagnosticMetrics();

  void updateSleepQuality(int value) {
    state = state.copyWith(sleepQuality: _clampMetric(value));
  }

  void updateSustainedAttention(int value) {
    state = state.copyWith(sustainedAttention: _clampMetric(value));
  }

  void updateFragmentation(int value) {
    state = state.copyWith(fragmentation: _clampMetric(value));
  }

  void updateDopamineSeeking(int value) {
    state = state.copyWith(dopamineSeeking: _clampMetric(value));
  }

  void updateTaskSwitching(int value) {
    state = state.copyWith(taskSwitching: _clampMetric(value));
  }

  void updateBurnout(int value) {
    state = state.copyWith(burnout: _clampMetric(value));
  }

  int _clampMetric(int value) => value.clamp(1, 10);

  Future<void> submitDiagnostic() async {
    final result = ref.read(bcScoreLiveProvider);
    final bhi = DiagnosticMetricsMapper.fromMetrics(state);
    final bhiScore = bhi.calculateBcScore();

    ref.read(bcScoreSessionProvider.notifier).commit(result);

    debugPrint(
      '[BrainClean] 6-point BC_score: ${result.bcScore.toStringAsFixed(1)}%',
    );
    debugPrint(
      '[BrainClean] BHI BC_score: ${bhiScore.toStringAsFixed(1)}% '
      '(performance ${bhi.brainPerformance.toStringAsFixed(0)}, '
      'discipline ${bhi.digitalDiscipline.toStringAsFixed(0)}, '
      'habits ${bhi.healthyHabits.toStringAsFixed(0)}, '
      'consistency ${bhi.consistency.toStringAsFixed(0)})',
    );
    debugPrint('[BrainClean] BHI JSON: ${bhi.toJson()}');
    // TODO: Supabase — upsert diagnostics row with result + metrics JSON

    ref.read(goRouterProvider).go(AppRoutes.dashboard);
  }
}
