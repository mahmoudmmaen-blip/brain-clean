import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_reminder_config.freezed.dart';
part 'smart_reminder_config.g.dart';

@freezed
class SmartReminderConfig with _$SmartReminderConfig {
  const factory SmartReminderConfig({
    @Default(false) bool isEnabled,
    int? detectedHour,
    DateTime? lastUpdated,
  }) = _SmartReminderConfig;

  factory SmartReminderConfig.fromJson(Map<String, dynamic> json) =>
      _$SmartReminderConfigFromJson(json);
}
