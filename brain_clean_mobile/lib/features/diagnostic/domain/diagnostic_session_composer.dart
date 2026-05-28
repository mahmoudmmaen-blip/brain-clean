import '../../detox/domain/detox_habit_scorer.dart';
import 'brain_rot_questionnaire_snapshot.dart';
import 'diagnostic_bhi_snapshot.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_metrics_mapper.dart';
import 'diagnostic_model.dart';
import 'diagnostic_session.dart';

/// Pure composition layer for [DiagnosticBhiSnapshot] and [DiagnosticSession].
///
/// All BHI pillar math, frozen snapshots, and session envelopes flow through here
/// so [DiagnosticController] and Riverpod providers share one authoritative path.
abstract final class DiagnosticSessionComposer {
  DiagnosticSessionComposer._();

  /// Maps slider metrics + detox habits into the live four-pillar [DiagnosticModel].
  static DiagnosticModel resolveLiveModel({
    required DiagnosticMetrics metrics,
    required bool boredomBefriended,
    required int delayedGratificationCount,
    required bool bodyActivated,
  }) {
    final base = DiagnosticMetricsMapper.fromMetrics(metrics);
    return DetoxHabitScorer.applyDetoxToModel(
      base,
      boredomBefriended: boredomBefriended,
      delayedGratificationCount: delayedGratificationCount,
      bodyActivated: bodyActivated,
    );
  }

  /// Freezes slider + live model into a coherent [DiagnosticBhiSnapshot].
  static DiagnosticBhiSnapshot composeLiveBhiSnapshot({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    DateTime? frozenAt,
    double recoveryPenaltyDeduction = 0,
  }) =>
      DiagnosticBhiSnapshot.compose(
        metrics: metrics,
        model: model,
        frozenAt: frozenAt,
        recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      );

  /// Active diagnostic flow — questionnaire may still be in progress.
  static DiagnosticSession buildInProgressSession({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BrainRotQuestionnaireSnapshot questionnaire,
    double recoveryPenaltyTotal = 0,
    bool requireComplete = false,
    DateTime? snapshotAt,
  }) {
    var session = DiagnosticSession.inProgress(
      metrics: metrics,
      model: model,
      questionnaire: questionnaire,
      snapshotAt: snapshotAt,
    );
    if (recoveryPenaltyTotal > 0) {
      session = session.withRecoveryPenaltyTotal(recoveryPenaltyTotal);
    }
    session.ensurePillarBoundCoherence();
    if (requireComplete || questionnaire.isComplete) {
      session.ensureBrainRotQuestionnaireCoherence();
    }
    return session;
  }

  /// Committed diagnostic after Brain Rot + BHI submit.
  static DiagnosticSession buildCommittedSession({
    required DiagnosticModel model,
    required DiagnosticMetrics metrics,
    required BrainRotInterpretation brainRot,
    required List<bool> brainRotAnswers,
    required BrainRotQuestionnaireSnapshot questionnaire,
    DateTime? committedAt,
  }) =>
      DiagnosticSession.fromAssessment(
        model: model,
        metrics: metrics,
        brainRot: brainRot,
        brainRotAnswers: brainRotAnswers,
        questionnaire: questionnaire,
        committedAt: committedAt,
      );
}
