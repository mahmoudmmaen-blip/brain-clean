import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_open_event.freezed.dart';
part 'app_open_event.g.dart';

@freezed
class AppOpenEvent with _$AppOpenEvent {
  const factory AppOpenEvent({
    required DateTime openedAt,
    required int hourOfDay,
  }) = _AppOpenEvent;

  factory AppOpenEvent.fromJson(Map<String, dynamic> json) =>
      _$AppOpenEventFromJson(json);
}
