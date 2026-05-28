import 'package:json_annotation/json_annotation.dart';

import 'diagnostic_model.dart';

part 'brain_rot_assessment.g.dart';

/// Serializable Brain Rot outcome + raw questionnaire answers.
@JsonSerializable()
class BrainRotAssessment {
  const BrainRotAssessment({
    required this.score,
    required this.interpretationBand,
    required this.interpretationAr,
    required this.answers,
    this.questionnaireCompletedAt,
  });

  final int score;

  @JsonKey(name: 'interpretation_band')
  final String interpretationBand;

  @JsonKey(name: 'interpretation_ar')
  final String interpretationAr;

  /// Exactly 10 entries — `true` = symptom present (نعم).
  final List<bool> answers;

  @JsonKey(name: 'questionnaire_completed_at')
  final String? questionnaireCompletedAt;

  InterpretationBand get band => InterpretationBand.values.firstWhere(
        (b) => b.name == interpretationBand,
        orElse: () => BrainRotTest.getBand(score),
      );

  factory BrainRotAssessment.fromInterpretation({
    required BrainRotInterpretation interpretation,
    required List<bool> answers,
    DateTime? completedAt,
  }) {
    return BrainRotAssessment(
      score: interpretation.score,
      interpretationBand: interpretation.band.name,
      interpretationAr: interpretation.interpretationAr,
      answers: List<bool>.from(answers),
      questionnaireCompletedAt: completedAt?.toUtc().toIso8601String(),
    );
  }

  BrainRotInterpretation toInterpretation() => BrainRotInterpretation(
        score: score,
        band: band,
        interpretationAr: interpretationAr,
      );

  factory BrainRotAssessment.fromJson(Map<String, dynamic> json) =>
      _$BrainRotAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$BrainRotAssessmentToJson(this);
}
