// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhi_pillar_frozen_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BhiPillarFrozenSnapshot _$BhiPillarFrozenSnapshotFromJson(
        Map<String, dynamic> json) =>
    BhiPillarFrozenSnapshot(
      brainPerformance: (json['brainPerformance'] as num).toDouble(),
      digitalDiscipline: (json['digitalDiscipline'] as num).toDouble(),
      healthyHabits: (json['healthyHabits'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      bcScore: (json['bcScore'] as num).toDouble(),
      frozenAt: DateTime.parse(json['frozenAt'] as String),
      recoveryPenaltyDeduction:
          (json['recoveryPenaltyDeduction'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$BhiPillarFrozenSnapshotToJson(
        BhiPillarFrozenSnapshot instance) =>
    <String, dynamic>{
      'brainPerformance': instance.brainPerformance,
      'digitalDiscipline': instance.digitalDiscipline,
      'healthyHabits': instance.healthyHabits,
      'consistency': instance.consistency,
      'bcScore': instance.bcScore,
      'frozenAt': instance.frozenAt.toIso8601String(),
      'recoveryPenaltyDeduction': instance.recoveryPenaltyDeduction,
    };
