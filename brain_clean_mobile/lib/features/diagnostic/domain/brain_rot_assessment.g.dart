// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_rot_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrainRotAssessment _$BrainRotAssessmentFromJson(Map<String, dynamic> json) =>
    BrainRotAssessment(
      score: (json['score'] as num).toInt(),
      interpretationBand: json['interpretation_band'] as String,
      interpretationAr: json['interpretation_ar'] as String,
      answers:
          (json['answers'] as List<dynamic>).map((e) => e as bool).toList(),
      questionnaireCompletedAt: json['questionnaire_completed_at'] as String?,
    );

Map<String, dynamic> _$BrainRotAssessmentToJson(BrainRotAssessment instance) =>
    <String, dynamic>{
      'score': instance.score,
      'interpretation_band': instance.interpretationBand,
      'interpretation_ar': instance.interpretationAr,
      'answers': instance.answers,
      'questionnaire_completed_at': instance.questionnaireCompletedAt,
    };
