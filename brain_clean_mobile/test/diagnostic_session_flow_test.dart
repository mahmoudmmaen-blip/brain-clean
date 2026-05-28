import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/bc_score_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_in_progress_session_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiagnosticSessionFlow', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          diagnosticControllerProvider.overrideWith(
            () => _TestDiagnosticController(),
          ),
          bcScoreLiveProvider.overrideWithValue(
            const DiagnosticModel(
              brainPerformance: 50,
              digitalDiscipline: 50,
              healthyHabits: 50,
              consistency: 50,
            ),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('each answer updates coherent in-progress session', () {
      final flow = container.read(diagnosticSessionFlowProvider.notifier);
      flow.answerQuestion(0, true);

      final session = container.read(diagnosticInProgressSessionProvider);
      expect(session.questionnaire.answers[0], isTrue);
      expect(session.isPillarBoundCoherent, isTrue);
      expect(session.questionnairePhase, BrainRotFlowPhase.questions);
    });

    test('10th answer validates and transitions to results dashboard', () {
      fakeAsync((async) {
        final flow = container.read(diagnosticSessionFlowProvider.notifier);

        for (var i = 0; i < 9; i++) {
          flow.answerQuestion(i, false);
        }
        flow.answerQuestion(9, true);

        expect(
          container.read(diagnosticSessionFlowProvider).pendingResultsTransition,
          isTrue,
        );
        expect(
          container.read(diagnosticSessionFlowProvider).phase,
          BrainRotFlowPhase.questions,
        );

        final pending = container.read(diagnosticInProgressSessionProvider);
        pending.ensureDiagnosticCoherence();
        expect(pending.brainRotScore, 1);

        async.elapse(kBrainRotResultsTransitionDelay);

        final snapshot = container.read(diagnosticSessionFlowProvider);
        expect(snapshot.pendingResultsTransition, isFalse);
        expect(snapshot.phase, BrainRotFlowPhase.results);

        final session = container.read(diagnosticInProgressSessionProvider);
        expect(session.brainRotScore, 1);
        expect(session.questionnairePhase, BrainRotFlowPhase.results);
        session.ensureDiagnosticCoherence();
      });
    });
  });
}

class _TestDiagnosticController extends DiagnosticController {
  @override
  Future<DiagnosticMetrics> build() async => const DiagnosticMetrics();
}
