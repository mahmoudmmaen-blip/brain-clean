// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worry_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorryEntryImpl _$$WorryEntryImplFromJson(Map<String, dynamic> json) =>
    _$WorryEntryImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sessionMinutes: (json['sessionMinutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$WorryEntryImplToJson(_$WorryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'sessionMinutes': instance.sessionMinutes,
    };
