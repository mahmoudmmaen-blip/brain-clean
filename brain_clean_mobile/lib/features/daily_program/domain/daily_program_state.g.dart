// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_program_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStepEntryImpl _$$DailyStepEntryImplFromJson(Map<String, dynamic> json) =>
    _$DailyStepEntryImpl(
      step: $enumDecode(_$DailyStepEnumMap, json['step']),
      status: $enumDecode(_$DailyStepStatusEnumMap, json['status']),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$DailyStepEntryImplToJson(
        _$DailyStepEntryImpl instance) =>
    <String, dynamic>{
      'step': _$DailyStepEnumMap[instance.step]!,
      'status': _$DailyStepStatusEnumMap[instance.status]!,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$DailyStepEnumMap = {
  DailyStep.dayStart: 'dayStart',
  DailyStep.water: 'water',
  DailyStep.movement: 'movement',
  DailyStep.sukoon: 'sukoon',
  DailyStep.focusTask: 'focusTask',
  DailyStep.mood: 'mood',
  DailyStep.journal: 'journal',
  DailyStep.dayEnd: 'dayEnd',
};

const _$DailyStepStatusEnumMap = {
  DailyStepStatus.locked: 'locked',
  DailyStepStatus.current: 'current',
  DailyStepStatus.done: 'done',
  DailyStepStatus.skipped: 'skipped',
};

_$DailyProgramStateImpl _$$DailyProgramStateImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyProgramStateImpl(
      date: DateTime.parse(json['date'] as String),
      dayNumber: (json['dayNumber'] as num).toInt(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => DailyStepEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DailyProgramStateImplToJson(
        _$DailyProgramStateImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'dayNumber': instance.dayNumber,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };
