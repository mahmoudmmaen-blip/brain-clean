import 'daily_session_path.dart';
import 'daily_session_reflection.dart';
import 'daily_session_version.dart';

/// Build Spec **SessionMarked** — durable daily completion mark.
class SessionMarked {
  const SessionMarked({
    required this.id,
    required this.dailySessionId,
    required this.todayActId,
    required this.planId,
    required this.dayKey,
    required this.path,
    required this.completedAt,
    required this.fullCompletion,
    required this.schemaVersion,
    this.reflection,
  });

  final String id;
  final String dailySessionId;
  final String todayActId;
  final String planId;
  final String dayKey;
  final DailySessionPath path;
  final DateTime completedAt;

  /// True when all required path steps were completed (not partial leave).
  final bool fullCompletion;
  final DailySessionReflection? reflection;
  final String schemaVersion;

  static String buildId(String dailySessionId) => 'smark_$dailySessionId';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'dailySessionId': dailySessionId,
        'todayActId': todayActId,
        'planId': planId,
        'dayKey': dayKey,
        'path': path.wireName,
        'completedAt': completedAt.toUtc().toIso8601String(),
        'fullCompletion': fullCompletion,
        if (reflection != null) 'reflection': reflection!.toJson(),
        'schemaVersion': schemaVersion,
      };

  factory SessionMarked.fromJson(Map<String, dynamic> json) {
    return SessionMarked(
      id: json['id'] as String? ?? '',
      dailySessionId: json['dailySessionId'] as String? ?? '',
      todayActId: json['todayActId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      dayKey: json['dayKey'] as String? ?? '',
      path: DailySessionPathX.fromWire(json['path'] as String?),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      fullCompletion: json['fullCompletion'] as bool? ?? false,
      reflection: json['reflection'] is Map
          ? DailySessionReflection.fromJson(
              Map<String, dynamic>.from(json['reflection'] as Map),
            )
          : null,
      schemaVersion:
          json['schemaVersion'] as String? ?? DailySessionVersion.schema,
    );
  }
}

/// Slice alias for completion record naming in tests/docs.
typedef DailySessionCompletion = SessionMarked;
