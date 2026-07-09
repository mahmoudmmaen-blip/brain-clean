// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_reminder_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmartReminderConfigImpl _$$SmartReminderConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$SmartReminderConfigImpl(
      isEnabled: json['isEnabled'] as bool? ?? false,
      detectedHour: (json['detectedHour'] as num?)?.toInt(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$SmartReminderConfigImplToJson(
        _$SmartReminderConfigImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'detectedHour': instance.detectedHour,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
