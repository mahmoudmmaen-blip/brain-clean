import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session_composer.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_bc_penalty_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_test_fixtures.dart';

/// Interactive overrides: real [diagnosticSessionFlowProvider] + reactive
/// [diagnosticLiveSessionProvider] (no frozen live-session stub).
List<Override> diagnosticInteractiveOverrides({
  DiagnosticMetrics metrics = const DiagnosticMetrics(),
  DiagnosticModel? liveModel,
  Box<dynamic>? diagnosticBox,
}) {
  final box = diagnosticBox ?? InMemoryHiveBox();
  final model = liveModel ??
      const DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );

  return [
    diagnosticLocalRepositoryProvider.overrideWithValue(
      DiagnosticLocalRepository(box: box),
    ),
    diagnosticControllerProvider.overrideWith(
      () => _SeededDiagnosticController(metrics, model),
    ),
    recoveryBcPenaltyTotalProvider.overrideWith((ref) => 0),
  ];
}

/// Committed session for widget tests — built via [DiagnosticSessionComposer] only.
DiagnosticSession composeWidgetTestCommittedSession({
  required DiagnosticModel model,
  DiagnosticMetrics metrics = const DiagnosticMetrics(),
  List<bool>? brainRotAnswers,
  DateTime? committedAt,
}) {
  final answers = brainRotAnswers ?? List<bool>.filled(10, false);
  final interpretation = DiagnosticModel.evaluateBrainRot(answers);
  return DiagnosticSessionComposer.buildCommittedSession(
    model: model,
    metrics: metrics,
    brainRot: interpretation,
    brainRotAnswers: answers,
    questionnaire: BrainRotQuestionnaireSnapshot(
      answers: answers.map<bool?>((a) => a).toList(growable: false),
      currentIndex: BrainRotTest.questionCount - 1,
      phase: BrainRotFlowPhase.bhiSliders,
    ),
    committedAt: committedAt ?? DateTime(2026, 5, 20, 12, 30),
  );
}

/// Standard Riverpod overrides for diagnostic UI widget tests.
///
/// Live session is resolved only through [DiagnosticController.buildLiveSession]
/// via [diagnosticLiveSessionProvider] (no frozen session stub).
List<Override> diagnosticWidgetTestOverrides({
  DiagnosticMetrics metrics = const DiagnosticMetrics(),
  DiagnosticModel? liveModel,
  BrainRotQuestionnaireSnapshot? questionnaireFlow,
  DiagnosticSession? committedSession,
  Box<dynamic>? diagnosticBox,
}) {
  final box = diagnosticBox ?? InMemoryHiveBox();
  final model = liveModel ??
      const DiagnosticModel(
        brainPerformance: 50,
        digitalDiscipline: 50,
        healthyHabits: 50,
        consistency: 50,
      );
  final flow = questionnaireFlow ?? const BrainRotQuestionnaireSnapshot();

  return [
    diagnosticLocalRepositoryProvider.overrideWithValue(
      DiagnosticLocalRepository(box: box),
    ),
    diagnosticControllerProvider.overrideWith(
      () => _SeededDiagnosticController(metrics, model, flowOverride: flow),
    ),
    diagnosticSessionFlowProvider.overrideWith(
      () => _FixedQuestionnaireFlow(flow),
    ),
    recoveryBcPenaltyTotalProvider.overrideWith((ref) => 0),
    if (committedSession != null)
      bcScoreSessionProvider.overrideWith(
        () => _FixedCommittedSession(committedSession),
      ),
  ];
}

class _SeededDiagnosticController extends DiagnosticController {
  _SeededDiagnosticController(
    this._metrics,
    this._liveModel, {
    this.flowOverride,
  });

  final DiagnosticMetrics _metrics;
  final DiagnosticModel _liveModel;
  final BrainRotQuestionnaireSnapshot? flowOverride;

  @override
  Future<DiagnosticMetrics> build() async => _metrics;

  @override
  DiagnosticModel computeLiveModel() => _liveModel;

  BrainRotQuestionnaireSnapshot _resolveQuestionnaire(
    BrainRotQuestionnaireSnapshot? questionnaire,
  ) =>
      questionnaire ??
      flowOverride ??
      ref.read(diagnosticSessionFlowProvider);

  @override
  DiagnosticSession buildLiveSession({
    BrainRotQuestionnaireSnapshot? questionnaire,
    double recoveryPenaltyTotal = 0,
    bool requireComplete = false,
  }) =>
      DiagnosticSessionComposer.buildLiveSession(
        metrics: _metrics,
        model: _liveModel,
        questionnaire: _resolveQuestionnaire(questionnaire),
        recoveryPenaltyTotal: recoveryPenaltyTotal,
        requireComplete: requireComplete,
      );
}

class _FixedQuestionnaireFlow extends DiagnosticSessionFlow {
  _FixedQuestionnaireFlow(this._snapshot);

  final BrainRotQuestionnaireSnapshot _snapshot;

  @override
  BrainRotQuestionnaireSnapshot build() => _snapshot;
}

class _FixedCommittedSession extends BcScoreSession {
  _FixedCommittedSession(this._session);

  final DiagnosticSession _session;

  @override
  DiagnosticSession? build() => _session;
}
