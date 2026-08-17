import 'brain_check_mode.dart';
import 'measurement_event.dart';
import 'recovery_score_bridge.dart';

/// Completed Brain Check outcome (CHK-04 → CHK-03 handoff).
///
/// Scoring mathematics stay at [RecoveryScorePlaceholder] until Recovery Score
/// connects via [RecoveryScoreBridge].
class BrainCheckResult {
  const BrainCheckResult({
    required this.mode,
    required this.completedAt,
    required this.answers,
    required this.measurementEvent,
    required this.scorePlaceholder,
    this.source,
    this.sessionId,
  });

  final BrainCheckMode mode;
  final DateTime completedAt;
  final Map<String, int> answers;
  final MeasurementEvent measurementEvent;
  final RecoveryScorePlaceholder scorePlaceholder;
  final String? source;
  final String? sessionId;

  bool get hasRecoveryScore => scorePlaceholder.recoveryScore != null;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mode': mode.wireName,
        'completedAt': completedAt.toUtc().toIso8601String(),
        'answers': answers,
        'measurementEvent': measurementEvent.toJson(),
        'scorePlaceholder': scorePlaceholder.toJson(),
        if (source != null) 'source': source,
        if (sessionId != null) 'sessionId': sessionId,
      };

  factory BrainCheckResult.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = <String, int>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is num) answers[key.toString()] = value.toInt();
      });
    }

    return BrainCheckResult(
      mode: BrainCheckModeX.fromWire(json['mode'] as String?),
      completedAt: DateTime.parse(json['completedAt'] as String).toUtc(),
      answers: Map<String, int>.unmodifiable(answers),
      measurementEvent: MeasurementEvent.fromJson(
        Map<String, dynamic>.from(json['measurementEvent'] as Map),
      ),
      scorePlaceholder: RecoveryScorePlaceholder.fromJson(
        Map<String, dynamic>.from(
          (json['scorePlaceholder'] as Map?) ?? const <String, dynamic>{},
        ),
      ),
      source: json['source'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }
}
