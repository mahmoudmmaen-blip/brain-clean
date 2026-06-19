import 'package:json_annotation/json_annotation.dart';

import 'bhi_pillar_json_keys.dart';
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

  @JsonKey(name: BhiPillarJsonKeys.score)
  final int score;

  @JsonKey(name: BhiPillarJsonKeys.interpretationBand)
  final String interpretationBand;

  @JsonKey(name: BhiPillarJsonKeys.interpretationAr)
  final String interpretationAr;

  /// Exactly 10 entries — `true` = symptom present (نعم).
  @JsonKey(name: BhiPillarJsonKeys.answers)
  final List<bool> answers;

  @JsonKey(name: BhiPillarJsonKeys.questionnaireCompletedAt)
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
      _$BrainRotAssessmentFromJson(
        BhiPillarJsonKeys.normalizeIncoming(json),
      );

  Map<String, dynamic> toJson() => _$BrainRotAssessmentToJson(this);
}
