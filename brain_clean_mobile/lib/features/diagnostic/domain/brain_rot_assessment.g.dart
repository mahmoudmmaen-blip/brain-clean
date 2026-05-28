// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_rot_assessment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrainRotAssessment _$BrainRotAssessmentFromJson(Map<String, dynamic> json) =>
    BrainRotAssessment(
      score: (json['score'] as num).toInt(),
      interpretationBand: json['interpretationBand'] as String,
      interpretationAr: json['interpretationAr'] as String,
      answers:
          (json['answers'] as List<dynamic>).map((e) => e as bool).toList(),
      questionnaireCompletedAt: json['questionnaireCompletedAt'] as String?,
    );

Map<String, dynamic> _$BrainRotAssessmentToJson(BrainRotAssessment instance) =>
    <String, dynamic>{
      'score': instance.score,
      'interpretationBand': instance.interpretationBand,
      'interpretationAr': instance.interpretationAr,
      'answers': instance.answers,
      'questionnaireCompletedAt': instance.questionnaireCompletedAt,
    };
