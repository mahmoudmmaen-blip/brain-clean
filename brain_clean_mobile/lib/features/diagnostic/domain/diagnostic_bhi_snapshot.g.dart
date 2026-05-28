// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_bhi_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosticBhiSnapshot _$DiagnosticBhiSnapshotFromJson(
        Map<String, dynamic> json) =>
    DiagnosticBhiSnapshot(
      metrics:
          DiagnosticMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      model: DiagnosticModel.fromJson(json['model'] as Map<String, dynamic>),
      frozenPillars: BhiPillarFrozenSnapshot.fromJson(
          json['frozen_pillars'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiagnosticBhiSnapshotToJson(
        DiagnosticBhiSnapshot instance) =>
    <String, dynamic>{
      'metrics': instance.metrics.toJson(),
      'model': instance.model.toJson(),
      'frozen_pillars': instance.frozenPillars.toJson(),
    };
