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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_test_fixtures.dart';

/// Standard Riverpod overrides for diagnostic UI widget tests.
///
/// Mocks Hive via [InMemoryHiveBox] and wires [diagnosticLiveSessionProvider]
/// so the grid never touches native I/O; live session is always pre-wired.
List<Override> diagnosticWidgetTestOverrides({
  DiagnosticMetrics metrics = const DiagnosticMetrics(),
  DiagnosticModel? liveModel,
  BrainRotQuestionnaireSnapshot? questionnaireFlow,
  DiagnosticSession? committedSession,
  DiagnosticSession? liveSession,
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

  final resolvedLiveSession = liveSession ??
      DiagnosticSessionComposer.buildLiveSession(
        metrics: metrics,
        model: model,
        questionnaire: flow,
      );

  return [
    diagnosticLocalRepositoryProvider.overrideWithValue(
      DiagnosticLocalRepository(box: box),
    ),
    diagnosticControllerProvider.overrideWith(
      () => _SeededDiagnosticController(metrics, model, flow),
    ),
    diagnosticLiveModelProvider.overrideWithValue(model),
    diagnosticSessionFlowProvider.overrideWith(
      () => _FixedQuestionnaireFlow(flow),
    ),
    diagnosticLiveSessionProvider.overrideWithValue(resolvedLiveSession),
    if (committedSession != null)
      bcScoreSessionProvider.overrideWith(
        () => _FixedCommittedSession(committedSession),
      ),
  ];
}

class _SeededDiagnosticController extends DiagnosticController {
  _SeededDiagnosticController(this._metrics, this._liveModel, this._flow);

  final DiagnosticMetrics _metrics;
  final DiagnosticModel _liveModel;
  final BrainRotQuestionnaireSnapshot _flow;

  @override
  Future<DiagnosticMetrics> build() async => _metrics;

  @override
  DiagnosticModel computeLiveModel() => _liveModel;

  @override
  DiagnosticSession buildLiveSession({
    BrainRotQuestionnaireSnapshot? questionnaire,
    double recoveryPenaltyTotal = 0,
    bool requireComplete = false,
  }) =>
      DiagnosticSessionComposer.buildLiveSession(
        metrics: _metrics,
        model: _liveModel,
        questionnaire: questionnaire ?? _flow,
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
