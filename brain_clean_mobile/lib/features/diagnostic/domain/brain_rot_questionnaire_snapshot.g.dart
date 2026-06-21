// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_rot_questionnaire_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrainRotQuestionnaireSnapshot _$BrainRotQuestionnaireSnapshotFromJson(
        Map<String, dynamic> json) =>
    BrainRotQuestionnaireSnapshot(
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => e as bool?)
              .toList() ??
          const [null, null, null, null, null, null, null, null, null, null],
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      phase: $enumDecodeNullable(_$BrainRotFlowPhaseEnumMap, json['phase']) ??
          BrainRotFlowPhase.questions,
    );

Map<String, dynamic> _$BrainRotQuestionnaireSnapshotToJson(
        BrainRotQuestionnaireSnapshot instance) =>
    <String, dynamic>{
      'answers': instance.answers,
      'currentIndex': instance.currentIndex,
      'phase': _$BrainRotFlowPhaseEnumMap[instance.phase]!,
    };

const _$BrainRotFlowPhaseEnumMap = {
  BrainRotFlowPhase.questions: 'questions',
  BrainRotFlowPhase.results: 'results',
  BrainRotFlowPhase.bhiSliders: 'bhiSliders',
};
