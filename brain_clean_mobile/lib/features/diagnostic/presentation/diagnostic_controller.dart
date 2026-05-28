import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../../detox/presentation/detox_protocol_controller.dart';
import '../../recovery/presentation/recovery_bc_penalty_provider.dart';
import '../data/diagnostic_local_repository_provider.dart';
import '../data/diagnostic_repository.dart';
import '../data/diagnostic_repository_provider.dart';
import '../domain/brain_rot_questionnaire_snapshot.dart';
import '../domain/diagnostic_bhi_snapshot.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_model.dart';
import '../domain/diagnostic_session.dart';
import '../domain/diagnostic_session_composer.dart';
import 'bc_score_provider.dart';
import 'diagnostic_session_flow_provider.dart';

part 'diagnostic_controller.g.dart';

/// Synchronous live BHI projection — sliders + detox recomputed on every watch.
@Riverpod(keepAlive: true)
DiagnosticModel diagnosticLiveModel(DiagnosticLiveModelRef ref) {
  ref.watch(diagnosticControllerProvider);
  ref.watch(detoxProtocolDataProvider);
  return ref.read(diagnosticControllerProvider.notifier).computeLiveModel();
}

/// Reactive live [DiagnosticSession] for diagnostic UI and breakdown widgets.
///
/// Rebuilds when metrics (async hydrate), questionnaire, live model, or penalties change.
@Riverpod(keepAlive: true)
DiagnosticSession diagnosticLiveSession(DiagnosticLiveSessionRef ref) {
  ref.watch(diagnosticControllerProvider);
  ref.watch(diagnosticSessionFlowProvider);
  ref.watch(diagnosticLiveModelProvider);

  final penaltyTotal = ref.watch(recoveryBcPenaltyTotalProvider);
  return ref.read(diagnosticControllerProvider.notifier).buildLiveSession(
        recoveryPenaltyTotal: penaltyTotal,
      );
}

/// Slider metrics, live model, and session packaging — single orchestrator.
///
/// - **Async**: [build] hydrates slider metrics from Hive (cold start).
/// - **Sync**: [computeLiveModel] / [buildLiveSession] project immediately on UI edits.
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

  /// Hydrated slider inputs (sync after [build] completes).
  DiagnosticMetrics get currentMetrics =>
      state.value ?? const DiagnosticMetrics();

  /// Whether metrics are still loading from Hive on first mount.
  bool get isMetricsLoading => state.isLoading;

  /// Synchronous live four-pillar model — safe to call during slider updates.
  DiagnosticModel computeLiveModel() {
    final detox = ref.read(detoxProtocolDataProvider);
    return DiagnosticSessionComposer.resolveLiveModel(
      metrics: currentMetrics,
      boredomBefriended: detox.boredomBefriended,
      delayedGratificationCount: detox.delayedGratificationCount,
      bodyActivated: detox.bodyActivated,
    );
  }

  void restoreFromPersistence(DiagnosticMetrics metrics) {
    if (!state.hasValue || state.value != metrics) {
      state = AsyncData(metrics);
    }
  }

  DiagnosticBhiSnapshot composeLiveBhiSnapshot({
    double recoveryPenaltyDeduction = 0,
    DateTime? frozenAt,
  }) =>
      DiagnosticSessionComposer.composeLiveBhiSnapshot(
        metrics: currentMetrics,
        model: computeLiveModel(),
        frozenAt: frozenAt,
        recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      );

  /// Authoritative live session for the diagnostic grid and breakdown.
  DiagnosticSession buildLiveSession({
    BrainRotQuestionnaireSnapshot? questionnaire,
    double recoveryPenaltyTotal = 0,
    bool requireComplete = false,
  }) =>
      DiagnosticSessionComposer.buildLiveSession(
        metrics: currentMetrics,
        model: computeLiveModel(),
        questionnaire:
            questionnaire ?? ref.read(diagnosticSessionFlowProvider),
        recoveryPenaltyTotal: recoveryPenaltyTotal,
        requireComplete: requireComplete,
      );

  /// Runs pillar + Brain Rot coherence checks (used after questionnaire commits).
  void validateLiveSession({
    BrainRotQuestionnaireSnapshot? questionnaire,
    bool requireComplete = false,
  }) {
    buildLiveSession(
      questionnaire: questionnaire,
      requireComplete: requireComplete,
    );
  }

  DiagnosticSession buildCommittedSession() {
    final flow = ref.read(diagnosticSessionFlowProvider);
    final interpretation = flow.interpretation;
    if (interpretation == null) {
      throw StateError('Brain Rot questionnaire is incomplete.');
    }
    return DiagnosticSessionComposer.buildCommittedSession(
      model: computeLiveModel(),
      metrics: currentMetrics,
      brainRot: interpretation,
      brainRotAnswers: flow.resolvedAnswers,
      questionnaire: flow,
    );
  }

  void _persistDraft() {
    if (!state.hasValue) return;
    ref.read(diagnosticLocalRepositoryProvider).saveDraft(
          metrics: state.value!,
        );
  }

  void _applyMetricUpdate(DiagnosticMetrics next) {
    state = AsyncData(next);
    _persistDraft();
  }

  void updateSleepQuality(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(
        state.value!.copyWith(sleepQuality: _clampMetric(value)),
      );
    }
  }

  void updateSustainedAttention(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(
        state.value!.copyWith(sustainedAttention: _clampMetric(value)),
      );
    }
  }

  void updateFragmentation(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(
        state.value!.copyWith(fragmentation: _clampMetric(value)),
      );
    }
  }

  void updateDopamineSeeking(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(
        state.value!.copyWith(dopamineSeeking: _clampMetric(value)),
      );
    }
  }

  void updateTaskSwitching(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(
        state.value!.copyWith(taskSwitching: _clampMetric(value)),
      );
    }
  }

  void updateBurnout(int value) {
    if (state.hasValue) {
      _applyMetricUpdate(state.value!.copyWith(burnout: _clampMetric(value)));
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
      final session = buildCommittedSession();
      session.ensureDiagnosticCoherence();

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
