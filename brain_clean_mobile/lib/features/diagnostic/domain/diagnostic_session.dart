import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_frozen_snapshot.dart';
import 'brain_rot_assessment.dart';
import 'brain_rot_questionnaire_snapshot.dart';
import 'diagnostic_bhi_snapshot.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_model.dart';

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

  @JsonKey(name: 'bhi')
  final DiagnosticBhiSnapshot bhi;

  @JsonKey(name: 'committed_at')
  final DateTime committedAt;

  @JsonKey(name: 'brain_rot')
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

  /// Pillar-bound BC_score — identical on screen, dashboard, and repository.
  double get bcScore => bhi.boundBcScore;

  int get bcScoreRounded => bcScore.round();

  /// Confirms frozen pillars and stored score cannot drift.
  bool get isPillarBoundCoherent => bhi.isPillarBoundCoherent;

  void ensurePillarBoundCoherence() {
    if (!isPillarBoundCoherent) {
      throw StateError(
        'DiagnosticSession pillar-bound score mismatch: '
        'stored=${frozenPillars.bcScore} recomputed=${frozenPillars.recomputedBcScore}',
      );
    }
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

  /// Ongoing diagnostic — re-freezes pillars on each provider rebuild while sliders move.
  factory DiagnosticSession.inProgress({
    required DiagnosticMetrics metrics,
    required DiagnosticModel model,
    required BrainRotQuestionnaireSnapshot questionnaire,
    DateTime? snapshotAt,
  }) {
    final at = snapshotAt ?? DateTime.now();
    return DiagnosticSession(
      bhi: DiagnosticBhiSnapshot.compose(
        metrics: metrics,
        model: model,
        frozenAt: at,
      ),
      committedAt: at,
      questionnaire: questionnaire,
    );
  }

  /// Builds a committed session from live assessment inputs (no field loss).
  factory DiagnosticSession.fromAssessment({
    required DiagnosticModel model,
    required DiagnosticMetrics metrics,
    required BrainRotInterpretation brainRot,
    required List<bool> brainRotAnswers,
    BrainRotQuestionnaireSnapshot? questionnaire,
    DateTime? committedAt,
  }) {
    final committed = committedAt ?? DateTime.now();
    final questionnaireSnapshot = questionnaire ??
        BrainRotQuestionnaireSnapshot(
          answers: brainRotAnswers
              .map<bool?>((a) => a)
              .toList(growable: false),
          currentIndex: BrainRotTest.questionCount - 1,
          phase: BrainRotFlowPhase.bhiSliders,
        );

    return DiagnosticSession(
      bhi: DiagnosticBhiSnapshot.compose(
        metrics: metrics,
        model: model,
        frozenAt: committed,
      ),
      committedAt: committed,
      brainRotAssessment: BrainRotAssessment.fromInterpretation(
        interpretation: brainRot,
        answers: brainRotAnswers,
        completedAt: committed,
      ),
      questionnaire: questionnaireSnapshot,
    );
  }

  factory DiagnosticSession.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticSessionFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticSessionToJson(this);

  /// Lossless snake_case payload for [DiagnosticRepository].
  Map<String, dynamic> toRepositoryPayload() {
    final input = metrics;
    final assessment = brainRotAssessment;
    final q = questionnaire;

    final frozen = frozenPillars;

    return {
      'bc_score': bcScore,
      'committed_at': committedAt.toUtc().toIso8601String(),
      'brain_performance': frozen.brainPerformance,
      'digital_discipline': frozen.digitalDiscipline,
      'healthy_habits': frozen.healthyHabits,
      'consistency': frozen.consistency,
      'bhi_frozen_at': frozen.frozenAt.toUtc().toIso8601String(),
      'bhi_frozen_bc_score': frozen.bcScore,
      'bhi_frozen_snapshot': frozen.toJson(),
      'questionnaire_json': q.toJson(),
      'mapped_brain_performance': bhi.mappedFromMetrics.brainPerformance,
      'mapped_digital_discipline': bhi.mappedFromMetrics.digitalDiscipline,
      'mapped_healthy_habits': bhi.mappedFromMetrics.healthyHabits,
      'mapped_consistency': bhi.mappedFromMetrics.consistency,
      'sleep_quality': input.sleepQuality,
      'sustained_attention': input.sustainedAttention,
      'fragmentation': input.fragmentation,
      'dopamine_seeking': input.dopamineSeeking,
      'task_switching': input.taskSwitching,
      'burnout': input.burnout,
      'questionnaire_phase': q.phase.name,
      'questionnaire_current_index': q.currentIndex,
      'questionnaire_answered_count': q.answeredCount,
      'session_json': toJson(),
      if (assessment != null) ...{
        'brain_rot_score': assessment.score,
        'interpretation_band': assessment.interpretationBand,
        'interpretation_ar': assessment.interpretationAr,
        'brain_rot_answers': assessment.answers,
        if (assessment.questionnaireCompletedAt != null)
          'questionnaire_completed_at': assessment.questionnaireCompletedAt,
      },
    };
  }
}
