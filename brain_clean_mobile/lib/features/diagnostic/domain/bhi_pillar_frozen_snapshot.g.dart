// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhi_pillar_frozen_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BhiPillarFrozenSnapshot _$BhiPillarFrozenSnapshotFromJson(
        Map<String, dynamic> json) =>
    BhiPillarFrozenSnapshot(
      brainPerformance: (json['brain_performance'] as num).toDouble(),
      digitalDiscipline: (json['digital_discipline'] as num).toDouble(),
      healthyHabits: (json['healthy_habits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      bcScore: (json['bc_score'] as num).toDouble(),
      frozenAt: DateTime.parse(json['frozen_at'] as String),
    );

Map<String, dynamic> _$BhiPillarFrozenSnapshotToJson(
        BhiPillarFrozenSnapshot instance) =>
    <String, dynamic>{
      'brain_performance': instance.brainPerformance,
      'digital_discipline': instance.digitalDiscipline,
      'healthy_habits': instance.healthyHabits,
      'consistency': instance.consistency,
      'bc_score': instance.bcScore,
      'frozen_at': instance.frozenAt.toIso8601String(),
    };
