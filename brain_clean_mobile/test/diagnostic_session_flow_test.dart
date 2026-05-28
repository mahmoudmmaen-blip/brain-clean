import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository_provider.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_controller.dart';
import 'package:brain_clean_mobile/features/diagnostic/presentation/diagnostic_session_flow_provider.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_storage_provider.dart';
import 'package:brain_clean_mobile/features/recovery/domain/recovery_protocol_state.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_bc_penalty_provider.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_protocol_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('DiagnosticSessionFlow', () {
    late ProviderContainer container;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('bc_flow_hive_');
      Hive.init(tempDir.path);
      final box = await Hive.openBox<dynamic>(HiveBoxes.diagnosticPersistence);
      container = ProviderContainer(
        overrides: [
          diagnosticLocalRepositoryProvider.overrideWithValue(
            DiagnosticLocalRepository(box: box),
          ),
          diagnosticControllerProvider.overrideWith(
            () => _TestDiagnosticController(),
          ),
          diagnosticLiveModelProvider.overrideWithValue(
            const DiagnosticModel(
              brainPerformance: 50,
              digitalDiscipline: 50,
              healthyHabits: 50,
              consistency: 50,
            ),
          ),
          recoveryProtocolStorageProvider.overrideWithValue(
            RecoveryProtocolMemoryRepository(),
          ),
          recoveryProtocolControllerProvider.overrideWith(
            () => _TestRecoveryProtocolController(),
          ),
          recoveryBcPenaltyTotalProvider.overrideWith((ref) => 0),
          recoveryDiagnosticPenaltySyncProvider.overrideWith(
            () => _NoOpPenaltySync(),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('each answer updates coherent in-progress session', () {
      final flow = container.read(diagnosticSessionFlowProvider.notifier);
      flow.answerQuestion(0, true);

      final session = container.read(diagnosticLiveSessionProvider);
      expect(session.questionnaire.answers[0], isTrue);
      expect(session.isPillarBoundCoherent, isTrue);
      expect(session.questionnairePhase, BrainRotFlowPhase.questions);
    });

    test(
      '10th answer validates and transitions to results dashboard',
      () async {
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

        final pending = container.read(diagnosticLiveSessionProvider);
        pending.ensureDiagnosticCoherence();
        expect(pending.brainRotScore, 1);

        await Future<void>.delayed(kBrainRotResultsTransitionDelay);

        final snapshot = container.read(diagnosticSessionFlowProvider);
        expect(snapshot.pendingResultsTransition, isFalse);
        expect(snapshot.phase, BrainRotFlowPhase.results);

        final session = container.read(diagnosticLiveSessionProvider);
        expect(session.brainRotScore, 1);
        expect(session.questionnairePhase, BrainRotFlowPhase.results);
        session.ensureDiagnosticCoherence();
      },
    );
  });
}

class _TestDiagnosticController extends DiagnosticController {
  @override
  Future<DiagnosticMetrics> build() async => const DiagnosticMetrics();
}

class _TestRecoveryProtocolController extends RecoveryProtocolController {
  @override
  Future<RecoveryProtocolState> build() async {
    return RecoveryProtocolState(protocolStartDate: DateTime(2026, 1, 1));
  }
}

class _NoOpPenaltySync extends RecoveryDiagnosticPenaltySync {
  @override
  void build() {}

  @override
  Future<void> syncFromRecoveryGrid() async {}
}
