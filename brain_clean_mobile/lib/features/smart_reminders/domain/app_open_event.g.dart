// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_open_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppOpenEventImpl _$$AppOpenEventImplFromJson(Map<String, dynamic> json) =>
    _$AppOpenEventImpl(
      openedAt: DateTime.parse(json['openedAt'] as String),
      hourOfDay: (json['hourOfDay'] as num).toInt(),
    );

Map<String, dynamic> _$$AppOpenEventImplToJson(_$AppOpenEventImpl instance) =>
    <String, dynamic>{
      'openedAt': instance.openedAt.toIso8601String(),
      'hourOfDay': instance.hourOfDay,
    };
