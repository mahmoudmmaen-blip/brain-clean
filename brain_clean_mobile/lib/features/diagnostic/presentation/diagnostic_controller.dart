import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../domain/diagnostic_model.dart';

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

  /// Computes score, logs (Supabase placeholder), navigates to dashboard.
  Future<void> submitDiagnostic() async {
    final score = state.calculateFocusScore();
    debugPrint(
      '[BrainClean] Diagnostic submitted — Focus Score: ${score.toStringAsFixed(1)}%',
    );
    debugPrint(
      '[BrainClean] Metrics: S1=${state.sleepQuality}, A2=${state.sustainedAttention}, '
      'F3=${state.fragmentation}, D4=${state.dopamineSeeking}, '
      'T5=${state.taskSwitching}, B6=${state.burnout}',
    );
    // TODO: persist to Supabase diagnostics table
    ref.read(goRouterProvider).go(AppRoutes.dashboard);
  }
}
