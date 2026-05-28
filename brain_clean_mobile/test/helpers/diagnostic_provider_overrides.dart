import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_test_fixtures.dart';

/// Standard Riverpod overrides for diagnostic UI widget tests.
///
/// Mocks Hive via [InMemoryHiveBox] and seeds [DiagnosticController] +
/// [diagnosticLiveSessionProvider] so the grid never touches native I/O.
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

  final overrides = <Override>[
    diagnosticLocalRepositoryProvider.overrideWithValue(
      DiagnosticLocalRepository(box: box),
    ),
    diagnosticControllerProvider.overrideWith(
      () => _SeededDiagnosticController(metrics, model),
    ),
    diagnosticLiveModelProvider.overrideWithValue(model),
  ];

  if (questionnaireFlow != null) {
    overrides.add(
      diagnosticSessionFlowProvider.overrideWith(
        () => _FixedQuestionnaireFlow(questionnaireFlow),
      ),
    );
  }

  if (liveSession != null) {
    overrides.add(
      diagnosticLiveSessionProvider.overrideWithValue(liveSession),
    );
  }

  if (committedSession != null) {
    overrides.add(
      bcScoreSessionProvider.overrideWith(
        () => _FixedCommittedSession(committedSession),
      ),
    );
  }

  return overrides;
}

class _SeededDiagnosticController extends DiagnosticController {
  _SeededDiagnosticController(this._metrics, this._liveModel);

  final DiagnosticMetrics _metrics;
  final DiagnosticModel _liveModel;

  @override
  Future<DiagnosticMetrics> build() async => _metrics;

  @override
  DiagnosticModel computeLiveModel() => _liveModel;
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
