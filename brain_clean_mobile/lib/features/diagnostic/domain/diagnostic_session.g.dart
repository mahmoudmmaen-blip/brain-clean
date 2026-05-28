// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosticSession _$DiagnosticSessionFromJson(Map<String, dynamic> json) =>
    DiagnosticSession(
      bhi: DiagnosticBhiSnapshot.fromJson(json['bhi'] as Map<String, dynamic>),
      committedAt: DateTime.parse(json['committed_at'] as String),
      brainRotAssessment: json['brain_rot'] == null
          ? null
          : BrainRotAssessment.fromJson(
              json['brain_rot'] as Map<String, dynamic>),
      questionnaire: json['questionnaire'] == null
          ? const BrainRotQuestionnaireSnapshot()
          : BrainRotQuestionnaireSnapshot.fromJson(
              json['questionnaire'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiagnosticSessionToJson(DiagnosticSession instance) =>
    <String, dynamic>{
      'bhi': instance.bhi.toJson(),
      'committed_at': instance.committedAt.toIso8601String(),
      'brain_rot': instance.brainRotAssessment?.toJson(),
      'questionnaire': instance.questionnaire.toJson(),
    };
