import 'package:freezed_annotation/freezed_annotation.dart';

part 'sukoon_session.freezed.dart';
part 'sukoon_session.g.dart';

@freezed
class SukoonSession with _$SukoonSession {
  const factory SukoonSession({
    required String id,
    required int durationMinutes,
    required DateTime completedAt,
    String? wanderNote,
    @Default(false) bool wasInterrupted,
  }) = _SukoonSession;

  factory SukoonSession.fromJson(Map<String, dynamic> json) =>
      _$SukoonSessionFromJson(json);
}
