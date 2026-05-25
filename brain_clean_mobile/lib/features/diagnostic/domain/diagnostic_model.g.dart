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
      boredomBefriended:
          _readBoredomBefriended(json, 'boredom_befriended') as bool? ?? false,
      delayedGratificationCount:
          (_readDelayedGratificationCount(json, 'delayed_gratification_count')
                      as num?)
                  ?.toInt() ??
              0,
      bodyActivated:
          _readBodyActivated(json, 'body_activated') as bool? ?? false,
    );

Map<String, dynamic> _$DiagnosticModelToJson(DiagnosticModel instance) =>
    <String, dynamic>{
      'brainPerformance': instance.brainPerformance,
      'digitalDiscipline': instance.digitalDiscipline,
      'healthyHabits': instance.healthyHabits,
      'consistency': instance.consistency,
      'boredom_befriended': instance.boredomBefriended,
      'delayed_gratification_count': instance.delayedGratificationCount,
      'body_activated': instance.bodyActivated,
    };
