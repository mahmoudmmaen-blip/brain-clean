// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sukoon_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SukoonSessionImpl _$$SukoonSessionImplFromJson(Map<String, dynamic> json) =>
    _$SukoonSessionImpl(
      id: json['id'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      wanderNote: json['wanderNote'] as String?,
      wasInterrupted: json['wasInterrupted'] as bool? ?? false,
    );

Map<String, dynamic> _$$SukoonSessionImplToJson(_$SukoonSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'durationMinutes': instance.durationMinutes,
      'completedAt': instance.completedAt.toIso8601String(),
      'wanderNote': instance.wanderNote,
      'wasInterrupted': instance.wasInterrupted,
    };
