import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../../detox/presentation/detox_protocol_controller.dart';
import '../data/diagnostic_local_repository_provider.dart';
import '../data/diagnostic_repository.dart';
import '../data/diagnostic_repository_provider.dart';
import '../domain/diagnostic_metrics.dart';
import 'bc_score_provider.dart';
import 'diagnostic_session_flow_provider.dart';

part 'diagnostic_controller.g.dart';

/// Slider metrics — keepAlive + Hive draft sync so cold start never wipes answers.
@Riverpod(keepAlive: true)
class DiagnosticController extends _$DiagnosticController {
  @override
  Future<DiagnosticMetrics> build() async {
    try {
      final bundle =
          await ref.read(diagnosticLocalRepositoryProvider).loadBundle();
      return bundle.metrics ?? const DiagnosticMetrics();
    } catch (e, stackTrace) {
      debugPrint('DiagnosticController: Hive hydrate failed: $e');
      debugPrint('$stackTrace');
      return const DiagnosticMetrics();
    }
  }

  void restoreFromPersistence(DiagnosticMetrics metrics) {
    if (!state.hasValue || state.value != metrics) {
      state = AsyncData(metrics);
    }
  }

  void _persistDraft() {
    if (!state.hasValue) return;
    ref.read(diagnosticLocalRepositoryProvider).saveDraft(
          metrics: state.value!,
        );
  }

  void updateSleepQuality(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(sleepQuality: _clampMetric(value)));
      _persistDraft();
    }
  }

  void updateSustainedAttention(int value) {
    if (state.hasValue) {
      state = AsyncData(
        state.value!.copyWith(sustainedAttention: _clampMetric(value)),
      );
      _persistDraft();
    }
  }

  void updateFragmentation(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(fragmentation: _clampMetric(value)));
      _persistDraft();
    }
  }

  void updateDopamineSeeking(int value) {
    if (state.hasValue) {
      state = AsyncData(
        state.value!.copyWith(dopamineSeeking: _clampMetric(value)),
      );
      _persistDraft();
    }
  }

  void updateTaskSwitching(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(taskSwitching: _clampMetric(value)));
      _persistDraft();
    }
  }

  void updateBurnout(int value) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(burnout: _clampMetric(value)));
      _persistDraft();
    }
  }

  int _clampMetric(int value) => value.clamp(1, 10);

  void _invalidateAndResyncDetox() {
    ref.invalidate(detoxProtocolControllerProvider);
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
      session.ensurePillarBoundCoherence();

      ref.read(bcScoreSessionProvider.notifier).commit(session);
      await ref.read(diagnosticLocalRepositoryProvider).clearDraft();

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
      ref.read(goRouterProvider).go(AppRoutes.home);
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
