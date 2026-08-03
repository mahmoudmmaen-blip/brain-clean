/// Neutral record of an optional-step skip (no penalty semantics).
class DailySessionSkip {
  const DailySessionSkip({
    required this.stepId,
    required this.skippedAt,
  });

  final String stepId;
  final DateTime skippedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stepId': stepId,
        'skippedAt': skippedAt.toUtc().toIso8601String(),
      };

  factory DailySessionSkip.fromJson(Map<String, dynamic> json) {
    return DailySessionSkip(
      stepId: json['stepId'] as String? ?? '',
      skippedAt: DateTime.tryParse(json['skippedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
