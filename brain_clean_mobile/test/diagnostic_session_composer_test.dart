import 'package:brain_clean_mobile/features/diagnostic/domain/brain_rot_questionnaire_snapshot.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_metrics.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_model.dart';
import 'package:brain_clean_mobile/features/diagnostic/domain/diagnostic_session_composer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiagnosticSessionComposer', () {
    test('buildLiveSession is pillar-bound coherent', () {
      const metrics = DiagnosticMetrics(sleepQuality: 8);
      const model = DiagnosticModel(
        brainPerformance: 60,
        digitalDiscipline: 55,
        healthyHabits: 50,
        consistency: 45,
      );
      const questionnaire = BrainRotQuestionnaireSnapshot(
        answers: [true, false, true, false, true, false, true, false, true, false],
        currentIndex: 9,
        phase: BrainRotFlowPhase.results,
      );

      final session = DiagnosticSessionComposer.buildLiveSession(
        metrics: metrics,
        model: model,
        questionnaire: questionnaire,
        requireComplete: true,
      );

      expect(session.isLive, isTrue);
      session.ensureDiagnosticCoherence();
      expect(session.brainRotScore, 5);
    });

    test('buildCommittedSession round-trips through BhiPillarJsonKeys session JSON', () {
      const metrics = DiagnosticMetrics(sleepQuality: 7);
      const model = DiagnosticModel(
        brainPerformance: 70,
        digitalDiscipline: 65,
        healthyHabits: 60,
        consistency: 55,
      );
      final interpretation = DiagnosticModel.evaluateBrainRot(
        List<bool>.filled(10, false),
      );
      final questionnaire = BrainRotQuestionnaireSnapshot(
        answers: List<bool?>.filled(10, false),
        currentIndex: 9,
        phase: BrainRotFlowPhase.bhiSliders,
      );

      final session = DiagnosticSessionComposer.buildCommittedSession(
        model: model,
        metrics: metrics,
        brainRot: interpretation,
        brainRotAnswers: List<bool>.filled(10, false),
        questionnaire: questionnaire,
      );

      final json = session.toJson();
      expect(json.containsKey('bhi'), isTrue);
      expect(json.containsKey('committedAt'), isTrue);
      session.ensureDiagnosticCoherence();
    });
  });
}
