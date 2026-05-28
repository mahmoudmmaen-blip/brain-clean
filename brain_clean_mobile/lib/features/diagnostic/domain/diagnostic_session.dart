import 'package:json_annotation/json_annotation.dart';

import 'brain_rot_assessment.dart';
import 'diagnostic_metrics.dart';
import 'diagnostic_model.dart';

part 'diagnostic_session.g.dart';

/// Committed diagnostic snapshot — BHI model, sliders, and Brain Rot payload.
@JsonSerializable(explicitToJson: true)
class DiagnosticSession {
  const DiagnosticSession({
    required this.model,
    required this.metrics,
    required this.committedAt,
    this.brainRotAssessment,
  });

  final DiagnosticModel model;
  final DiagnosticMetrics metrics;

  @JsonKey(name: 'committed_at')
  final DateTime committedAt;

  @JsonKey(name: 'brain_rot')
  final BrainRotAssessment? brainRotAssessment;

  double get bcScore => model.calculateBcScore();

  int get bcScoreRounded => bcScore.round();

  int? get brainRotScore => brainRotAssessment?.score;

  InterpretationBand? get brainRotBand => brainRotAssessment?.band;

  String? get brainRotInterpretationAr => brainRotAssessment?.interpretationAr;

  List<bool>? get brainRotAnswers => brainRotAssessment?.answers;

  BrainRotInterpretation? get brainRot =>
      brainRotAssessment?.toInterpretation();

  /// Builds a complete session from live assessment inputs.
  factory DiagnosticSession.fromAssessment({
    required DiagnosticModel model,
    required DiagnosticMetrics metrics,
    required BrainRotInterpretation brainRot,
    required List<bool> brainRotAnswers,
    DateTime? committedAt,
  }) {
    return DiagnosticSession(
      model: model,
      metrics: metrics,
      committedAt: committedAt ?? DateTime.now(),
      brainRotAssessment: BrainRotAssessment.fromInterpretation(
        interpretation: brainRot,
        answers: brainRotAnswers,
        completedAt: committedAt ?? DateTime.now(),
      ),
    );
  }

  factory DiagnosticSession.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticSessionFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosticSessionToJson(this);

  /// Flat snake_case map for [DiagnosticRepository] — no dropped fields.
  Map<String, dynamic> toRepositoryPayload() {
    final payload = <String, dynamic>{
      'bc_score': bcScore,
      'committed_at': committedAt.toUtc().toIso8601String(),
      'brain_performance': model.brainPerformance,
      'digital_discipline': model.digitalDiscipline,
      'healthy_habits': model.healthyHabits,
      'consistency': model.consistency,
      'sleep_quality': metrics.sleepQuality,
      'sustained_attention': metrics.sustainedAttention,
      'fragmentation': metrics.fragmentation,
      'dopamine_seeking': metrics.dopamineSeeking,
      'task_switching': metrics.taskSwitching,
      'burnout': metrics.burnout,
      'session_json': toJson(),
    };
    final assessment = brainRotAssessment;
    if (assessment != null) {
      payload.addAll({
        'brain_rot_score': assessment.score,
        'interpretation_band': assessment.interpretationBand,
        'interpretation_ar': assessment.interpretationAr,
        'brain_rot_answers': assessment.answers,
        if (assessment.questionnaireCompletedAt != null)
          'questionnaire_completed_at': assessment.questionnaireCompletedAt,
      });
    }
    return payload;
  }
}
