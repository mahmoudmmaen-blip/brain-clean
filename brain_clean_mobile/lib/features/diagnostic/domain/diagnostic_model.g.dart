// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiagnosticMetricsImpl _$$DiagnosticMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$DiagnosticMetricsImpl(
      sleepQuality: (json['sleepQuality'] as num?)?.toInt() ?? 5,
      sustainedAttention: (json['sustainedAttention'] as num?)?.toInt() ?? 5,
      fragmentation: (json['fragmentation'] as num?)?.toInt() ?? 5,
      dopamineSeeking: (json['dopamineSeeking'] as num?)?.toInt() ?? 5,
      taskSwitching: (json['taskSwitching'] as num?)?.toInt() ?? 5,
      burnout: (json['burnout'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$$DiagnosticMetricsImplToJson(
        _$DiagnosticMetricsImpl instance) =>
    <String, dynamic>{
      'sleepQuality': instance.sleepQuality,
      'sustainedAttention': instance.sustainedAttention,
      'fragmentation': instance.fragmentation,
      'dopamineSeeking': instance.dopamineSeeking,
      'taskSwitching': instance.taskSwitching,
      'burnout': instance.burnout,
    };
