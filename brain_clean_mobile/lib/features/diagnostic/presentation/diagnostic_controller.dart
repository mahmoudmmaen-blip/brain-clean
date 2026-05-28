import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/routing/app_router.dart';
import '../../detox/presentation/detox_protocol_controller.dart';
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

/// Live four-pillar model — recomputes when sliders or detox habits change.
@Riverpod(keepAlive: true)
DiagnosticModel diagnosticLiveModel(DiagnosticLiveModelRef ref) {
  final metrics =
      ref.watch(diagnosticControllerProvider).value ?? const DiagnosticMetrics();
  final detox = ref.watch(detoxProtocolDataProvider);
  return DiagnosticSessionComposer.resolveLiveModel(
    metrics: metrics,
    boredomBefriended: detox.boredomBefriended,
    delayedGratificationCount: detox.delayedGratificationCount,
    bodyActivated: detox.bodyActivated,
  );
}

/// Slider metrics, BHI composition, and session packaging (single orchestrator).
///
/// Persistence: drafts written on every slider change; committed sessions flow
/// through [BcScoreSession.commit] → [DiagnosticLocalRepository].
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

  DiagnosticMetrics get currentMetrics =>
      state.value ?? const DiagnosticMetrics();

  /// Live detox-adjusted model for the active diagnostic flow.
  DiagnosticModel get liveModel => ref.read(diagnosticLiveModelProvider);

  void restoreFromPersistence(DiagnosticMetrics metrics) {
    if (!state.hasValue || state.value != metrics) {
      state = AsyncData(metrics);
    }
  }

  /// Freezes current slider + live model into a coherent [DiagnosticBhiSnapshot].
  DiagnosticBhiSnapshot composeLiveBhiSnapshot({
    double recoveryPenaltyDeduction = 0,
    DateTime? frozenAt,
  }) =>
      DiagnosticSessionComposer.composeLiveBhiSnapshot(
        metrics: currentMetrics,
        model: liveModel,
        frozenAt: frozenAt,
        recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      );

  /// Unified in-progress [DiagnosticSession] for UI and coherence validation.
  DiagnosticSession buildInProgressSession({
    BrainRotQuestionnaireSnapshot? questionnaire,
    double recoveryPenaltyTotal = 0,
    bool requireComplete = false,
  }) =>
      DiagnosticSessionComposer.buildInProgressSession(
        metrics: currentMetrics,
        model: liveModel,
        questionnaire:
            questionnaire ?? ref.read(diagnosticSessionFlowProvider),
        recoveryPenaltyTotal: recoveryPenaltyTotal,
        requireComplete: requireComplete,
      );

  /// Packages questionnaire + BHI into a committed [DiagnosticSession].
  DiagnosticSession buildCommittedSession() {
    final flow = ref.read(diagnosticSessionFlowProvider);
    final interpretation = flow.interpretation;
    if (interpretation == null) {
      throw StateError('Brain Rot questionnaire is incomplete.');
    }
    return DiagnosticSessionComposer.buildCommittedSession(
      model: liveModel,
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
