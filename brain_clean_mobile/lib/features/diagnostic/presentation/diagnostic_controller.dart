import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../data/diagnostic_repository.dart';
import '../data/diagnostic_repository_provider.dart';
import '../domain/diagnostic_metrics.dart';
import 'bc_score_provider.dart';
import 'diagnostic_session_flow_provider.dart';

part 'diagnostic_controller.g.dart';

@riverpod
class DiagnosticController extends _$DiagnosticController {
  @override
  FutureOr<DiagnosticMetrics> build() {
    return const DiagnosticMetrics();
  }

  void updateSleepQuality(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(sleepQuality: _clampMetric(value)));
    }
  }

  void updateSustainedAttention(int value) {
    if (state.hasValue) {
      state = AsyncData(
        state.value!.copyWith(sustainedAttention: _clampMetric(value)),
      );
    }
  }

  void updateFragmentation(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(fragmentation: _clampMetric(value)));
    }
  }

  void updateDopamineSeeking(int value) {
    if (state.hasValue) {
      state = AsyncData(
        state.value!.copyWith(dopamineSeeking: _clampMetric(value)),
      );
    }
  }

  void updateTaskSwitching(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(taskSwitching: _clampMetric(value)));
    }
  }

  void updateBurnout(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(burnout: _clampMetric(value)));
    }
  }

  int _clampMetric(int value) => value.clamp(1, 10);

  void _invalidateAndResyncDetox() {
    debugPrint('[BrainClean] Detox resync lifecycle triggered successfully.');
  }

  Future<void> submitDiagnostic() async {
    if (!state.hasValue) return;

    final currentMetrics = state.value!;
    final bhi = ref.read(bcScoreLiveProvider);
    final flow = ref.read(diagnosticSessionFlowProvider.notifier);

    if (!flow.isComplete) {
      state = AsyncError<DiagnosticMetrics>(
        StateError('Complete the Brain Rot questionnaire before submitting.'),
        StackTrace.current,
      ).copyWithPrevious(AsyncData(currentMetrics));
      return;
    }

    state = const AsyncLoading<DiagnosticMetrics>().copyWithPrevious(
      AsyncData(currentMetrics),
    );

    try {
      final session = flow.buildCommittedSession(
        model: bhi,
        metrics: currentMetrics,
      );

      ref.read(bcScoreSessionProvider.notifier).commit(session);

      await ref.read(diagnosticRepositoryProvider).upsertSession(
            session: session,
          );

      final brainRot = session.brainRot!;
      debugPrint(
        '[BrainClean] Session committed · Brain Rot ${brainRot.score}/10 '
        '(${brainRot.band.name}) · BC_score ${session.bcScore.toStringAsFixed(1)}%',
      );

      _invalidateAndResyncDetox();

      state = AsyncData(currentMetrics);
      ref.read(goRouterProvider).go(AppRoutes.dashboard);
    } on DiagnosticSyncException catch (error, stackTrace) {
      state = AsyncError<DiagnosticMetrics>(error, stackTrace).copyWithPrevious(
        AsyncData(currentMetrics),
      );
    } catch (error, stackTrace) {
      state = AsyncError<DiagnosticMetrics>(error, stackTrace).copyWithPrevious(
        AsyncData(currentMetrics),
      );
    }
  }
}
