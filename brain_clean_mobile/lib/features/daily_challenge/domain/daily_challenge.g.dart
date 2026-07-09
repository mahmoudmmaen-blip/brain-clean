// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyChallengeImpl _$$DailyChallengeImplFromJson(Map<String, dynamic> json) =>
    _$DailyChallengeImpl(
      date: DateTime.parse(json['date'] as String),
      gameKey: json['gameKey'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$DailyChallengeImplToJson(
        _$DailyChallengeImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'gameKey': instance.gameKey,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
