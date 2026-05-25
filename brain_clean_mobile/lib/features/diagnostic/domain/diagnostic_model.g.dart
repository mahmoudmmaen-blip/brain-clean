// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosticModel _$DiagnosticModelFromJson(Map<String, dynamic> json) =>
    DiagnosticModel(
      brainPerformance: (json['brainPerformance'] as num).toDouble(),
      digitalDiscipline: (json['digitalDiscipline'] as num).toDouble(),
      healthyHabits: (json['healthyHabits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      boredomBefriended: json['boredomBefriended'] as bool? ?? false,
      delayedGratificationCount:
          (json['delayedGratificationCount'] as num?)?.toInt() ?? 0,
      bodyActivated: json['bodyActivated'] as bool? ?? false,
    );

Map<String, dynamic> _$DiagnosticModelToJson(DiagnosticModel instance) =>
    <String, dynamic>{
      'brainPerformance': instance.brainPerformance,
      'digitalDiscipline': instance.digitalDiscipline,
      'healthyHabits': instance.healthyHabits,
      'consistency': instance.consistency,
      'boredomBefriended': instance.boredomBefriended,
      'delayedGratificationCount': instance.delayedGratificationCount,
      'bodyActivated': instance.bodyActivated,
    };
