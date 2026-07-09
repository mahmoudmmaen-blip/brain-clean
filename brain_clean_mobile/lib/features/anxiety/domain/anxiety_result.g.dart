// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anxiety_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnxietyResultImpl _$$AnxietyResultImplFromJson(Map<String, dynamic> json) =>
    _$AnxietyResultImpl(
      answers: (json['answers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      score: (json['score'] as num).toDouble(),
      level: $enumDecode(_$AnxietyLevelEnumMap, json['level']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$AnxietyResultImplToJson(_$AnxietyResultImpl instance) =>
    <String, dynamic>{
      'answers': instance.answers,
      'score': instance.score,
      'level': _$AnxietyLevelEnumMap[instance.level]!,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$AnxietyLevelEnumMap = {
  AnxietyLevel.calm: 'calm',
  AnxietyLevel.moderate: 'moderate',
  AnxietyLevel.high: 'high',
  AnxietyLevel.severe: 'severe',
};
