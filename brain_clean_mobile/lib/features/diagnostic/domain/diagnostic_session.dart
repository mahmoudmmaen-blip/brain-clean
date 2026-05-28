import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_frozen_snapshot.dart';
import 'bhi_pillar_json_keys.dart';
import 'brain_rot_assessment.dart';
import 'brain_rot_questionnaire_snapshot.dart';
import 'diagnostic_bhi_snapshot.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_model.dart';
import 'pillar_bound_evaluation.dart';

part 'diagnostic_session.g.dart';

/// Full diagnostic commit — BHI snapshot, questionnaire, and Brain Rot outcome.
@JsonSerializable(explicitToJson: true)
class DiagnosticSession {
  const DiagnosticSession({
    required this.bhi,
    required this.committedAt,
    this.brainRotAssessment,
    this.questionnaire = const BrainRotQuestionnaireSnapshot(),
  });

  @JsonKey(name: BhiPillarJsonKeys.bhi)
  final DiagnosticBhiSnapshot bhi;

  @JsonKey(name: BhiPillarJsonKeys.committedAt)
  final DateTime committedAt;

  @JsonKey(name: BhiPillarJsonKeys.brainRot)
  final BrainRotAssessment? brainRotAssessment;

  final BrainRotQuestionnaireSnapshot questionnaire;

  /// Live fluid model (detox/habits may change). Prefer [pillarModel] for scoring UI.
  DiagnosticModel get model => bhi.model;

  /// Immutable pillar-bound model — authoritative for BC_score and breakdowns.
  DiagnosticModel get pillarModel => bhi.pillarModel;

  /// Slider input metrics (alias).
  DiagnosticMetrics get metrics => bhi.metrics;

  /// Active questionnaire flow (not yet submitted to [bcScoreSessionProvider]).
  bool get isInProgress => !isCommitted;

  /// Pillar values frozen at session save (committed sessions are authoritative).
  BhiPillarFrozenSnapshot get frozenPillars => bhi.frozenPillars;

  double get frozenBrainPerformance => frozenPillars.brainPerformance;

  double get frozenDigitalDiscipline => frozenPillars.digitalDiscipline;

  double get frozenHealthyHabits => frozenPillars.healthyHabits;

  double get frozenConsistency => frozenPillars.consistency;

  /// Authoritative pillar matrix for all diagnostic UI score widgets.
  PillarBoundEvaluation get pillarEvaluation => bhi.pillarEvaluation;

  /// Pillar-bound BC_score — includes recovery-grid penalties when present.
  double get bcScore => frozenPillars.bcScore;

  /// Weighted four-pillar matrix before recovery accountability deductions.
  double get pillarMatrixBcScore => frozenPillars.pillarMatrixBcScore;

  /// Cumulative points deducted via recovery penalty box confirmations.
  double get recoveryPenaltyDeduction => frozenPillars.recoveryPenaltyDeduction;

  bool get hasRecoveryPenalty => frozenPillars.hasRecoveryPenalty;

  int get bcScoreRounded => bcScore.round();

  /// Confirms frozen pillars and stored score cannot drift.
  bool get isPillarBoundCoherent => bhi.isPillarBoundCoherent;

  void ensurePillarBoundCoherence() {
    bhi.ensurePillarBoundCoherence();
    pillarEvaluation.ensureCoherent();
    PillarBoundEvaluation.requireScoresMatch(
      stored: bcScore,
      recomputed: frozenPillars.recomputedBcScore,
      layer: 'DiagnosticSession',
    );
  }

  /// Validates questionnaire interpretation against Dr. Moneam scoring rules.
  void ensureBrainRotQuestionnaireCoherence() {
    if (!questionnaire.isComplete) return;
    final interpretation = questionnaire.interpretation;
    if (interpretation == null) {
      throw StateError(
        'DiagnosticSession: questionnaire complete but interpretation is null.',
      );
    }
    BrainRotTest.requireInterpretationMatch(
      stored: interpretation,
      answers: questionnaire.resolvedAnswers,
      layer: 'DiagnosticSession.questionnaire',
    );
    final live = brainRot;
    if (live != null) {
      BrainRotTest.requireInterpretationMatch(
        stored: live,
        answers: questionnaire.resolvedAnswers,
        layer: 'DiagnosticSession.brainRot',
      );
    }
  }

  /// Pillar ε-check plus Brain Rot interpretation when the questionnaire is done.
  void ensureDiagnosticCoherence() {
    ensurePillarBoundCoherence();
    ensureBrainRotQuestionnaireCoherence();
  }

  /// Applies cumulative recovery-grid accountability to the frozen BHI snapshot.
  DiagnosticSession withRecoveryPenaltyTotal(double totalRecoveryPenaltyDeduction) {
    final frozen = bhi.frozenPillars;
    final nextFrozen = frozen.copyWith(
      recoveryPenaltyDeduction: totalRecoveryPenaltyDeduction,
    );
    nextFrozen.ensureCoherent();

    final nextBhi = DiagnosticBhiSnapshot.withFrozenPillars(
      metrics: metrics,
      model: model,
      frozenPillars: nextFrozen,
    );

    final next = DiagnosticSession(
      bhi: nextBhi,
      committedAt: committedAt,
      brainRotAssessment: brainRotAssessment,
      questionnaire: questionnaire,
    );
    next.ensureDiagnosticCoherence();
    return next;
  }

  int? get brainRotScore => brainRot?.score;

  InterpretationBand? get brainRotBand => brainRot?.band;

  String? get brainRotInterpretationAr =>
      brainRotAssessment?.interpretationAr ?? brainRot?.interpretationAr;

  List<bool>? get brainRotAnswers =>
      brainRotAssessment?.answers ??
      (questionnaire.isComplete ? questionnaire.resolvedAnswers : null);

  /// Committed assessment, or live questionnaire interpretation while in flow.
  BrainRotInterpretation? get brainRot =>
      brainRotAssessment?.toInterpretation() ?? questionnaire.interpretation;

  BrainRotFlowPhase get questionnairePhase => questionnaire.phase;

  /// True after [DiagnosticSession.fromAssessment] submit (persisted bundle).
  bool get isCommitted => brainRotAssessment != null;

  /// In-progress diagnostic (questionnaire active, not yet committed).
  factory DiagnosticSession.inProgress({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BrainRotQuestionnaireSnapshot questionnaire,
    DateTime? snapshotAt,
  }) =>
      DiagnosticSession._validated(
        metrics: metrics,
        model: model,
        questionnaire: questionnaire,
        committedAt: snapshotAt ?? DateTime.now(),
      );

  /// Committed diagnostic after Brain Rot + BHI submit.
  factory DiagnosticSession.fromAssessment({
    required DiagnosticModel model,
    required DiagnosticMetrics metrics,
    required BrainRotInterpretation brainRot,
    required List<bool> brainRotAnswers,
    BrainRotQuestionnaireSnapshot? questionnaire,
    DateTime? committedAt,
  }) {
    final committed = committedAt ?? DateTime.now();
    return DiagnosticSession._validated(
      metrics: metrics,
      model: model,
      committedAt: committed,
      questionnaire: questionnaire ??
          BrainRotQuestionnaireSnapshot(
            answers: brainRotAnswers
                .map<bool?>((a) => a)
                .toList(growable: false),
            currentIndex: BrainRotTest.questionCount - 1,
            phase: BrainRotFlowPhase.bhiSliders,
          ),
      brainRotAssessment: BrainRotAssessment.fromInterpretation(
        interpretation: brainRot,
        answers: brainRotAnswers,
        completedAt: committed,
      ),
    );
  }

  /// Shared emit path: coherent BHI snapshot → session → ε-validated.
  factory DiagnosticSession._validated({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BrainRotQuestionnaireSnapshot questionnaire,
    required DateTime committedAt,
    BrainRotAssessment? brainRotAssessment,
  }) {
    final session = DiagnosticSession(
      bhi: DiagnosticBhiSnapshot.compose(
        metrics: metrics,
        model: model,
        frozenAt: committedAt,
      ),
      committedAt: committedAt,
      brainRotAssessment: brainRotAssessment,
      questionnaire: questionnaire,
    );
    session.ensureDiagnosticCoherence();
    return session;
  }

  factory DiagnosticSession.fromJson(Map<String, dynamic> json) {
    final normalized = BhiPillarJsonKeys.normalizeIncoming(json);
    final session = _$DiagnosticSessionFromJson(normalized);
    final rootPenalty = BhiPillarJsonKeys.readPenalty(normalized);
    if (rootPenalty > 0) {
      PillarBoundEvaluation.requireScoresMatch(
        stored: rootPenalty,
        recomputed: session.recoveryPenaltyDeduction,
        layer: 'DiagnosticSession.recoveryPenaltyDeduction',
      );
    }
    session.ensurePillarBoundCoherence();
    return session;
  }

  Map<String, dynamic> toJson() {
    ensurePillarBoundCoherence();
    final map = _$DiagnosticSessionToJson(this);
    BhiPillarJsonKeys.writePenaltyEnvelope(
      map,
      recoveryPenaltyDeduction: recoveryPenaltyDeduction,
      pillarMatrixBcScore: pillarMatrixBcScore,
      boundBcScore: bcScore,
    );
    return map;
  }

  /// Lossless snake_case payload for [DiagnosticRepository].
  Map<String, dynamic> toRepositoryPayload() {
    ensurePillarBoundCoherence();
    final input = metrics;
    final assessment = brainRotAssessment;
    final q = questionnaire;

    final frozen = frozenPillars;

    return {
      BhiPillarJsonKeys.bcScoreSnake: bcScore,
      BhiPillarJsonKeys.pillarMatrixBcScoreSnake: frozen.pillarMatrixBcScore,
      BhiPillarJsonKeys.recoveryPenaltyDeductionSnake:
          frozen.recoveryPenaltyDeduction,
      BhiPillarJsonKeys.committedAtSnake:
          committedAt.toUtc().toIso8601String(),
      BhiPillarJsonKeys.brainPerformanceSnake: frozen.brainPerformance,
      BhiPillarJsonKeys.digitalDisciplineSnake: frozen.digitalDiscipline,
      BhiPillarJsonKeys.healthyHabitsSnake: frozen.healthyHabits,
      BhiPillarJsonKeys.consistencySnake: frozen.consistency,
      BhiPillarJsonKeys.bhiFrozenAtSnake:
          frozen.frozenAt.toUtc().toIso8601String(),
      BhiPillarJsonKeys.bhiFrozenBcScoreSnake: frozen.bcScore,
      BhiPillarJsonKeys.bhiFrozenSnapshotSnake: frozen.toJson(),
      BhiPillarJsonKeys.questionnaireJsonSnake: q.toJson(),
      BhiPillarJsonKeys.mappedBrainPerformanceSnake:
          bhi.mappedFromMetrics.brainPerformance,
      BhiPillarJsonKeys.mappedDigitalDisciplineSnake:
          bhi.mappedFromMetrics.digitalDiscipline,
      BhiPillarJsonKeys.mappedHealthyHabitsSnake:
          bhi.mappedFromMetrics.healthyHabits,
      BhiPillarJsonKeys.mappedConsistencySnake:
          bhi.mappedFromMetrics.consistency,
      BhiPillarJsonKeys.sleepQualitySnake: input.sleepQuality,
      BhiPillarJsonKeys.sustainedAttentionSnake: input.sustainedAttention,
      BhiPillarJsonKeys.fragmentationSnake: input.fragmentation,
      BhiPillarJsonKeys.dopamineSeekingSnake: input.dopamineSeeking,
      BhiPillarJsonKeys.taskSwitchingSnake: input.taskSwitching,
      BhiPillarJsonKeys.burnoutSnake: input.burnout,
      BhiPillarJsonKeys.questionnairePhaseSnake: q.phase.name,
      BhiPillarJsonKeys.questionnaireCurrentIndexSnake: q.currentIndex,
      BhiPillarJsonKeys.questionnaireAnsweredCountSnake: q.answeredCount,
      BhiPillarJsonKeys.sessionJsonSnake: toJson(),
      if (assessment != null) ...{
        BhiPillarJsonKeys.brainRotScoreSnake: assessment.score,
        BhiPillarJsonKeys.interpretationBandSnake: assessment.interpretationBand,
        BhiPillarJsonKeys.interpretationArSnake: assessment.interpretationAr,
        BhiPillarJsonKeys.brainRotAnswersSnake: assessment.answers,
        if (assessment.questionnaireCompletedAt != null)
          BhiPillarJsonKeys.questionnaireCompletedAtSnake:
              assessment.questionnaireCompletedAt,
      },
    };
  }
}
