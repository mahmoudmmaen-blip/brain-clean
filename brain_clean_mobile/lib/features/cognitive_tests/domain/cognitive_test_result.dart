/// Result from a cognitive mini-game module.
class CognitiveTestResult {
  const CognitiveTestResult({
    required this.testId,
    required this.normalizedScore,
    required this.completedAt,
    this.longestSuccessfulSpan,
    this.visualTotalPoints,
    this.visualRoundsPlayed,
  });

  static const testIdKey = 'testId';
  static const normalizedScoreKey = 'normalizedScore';
  static const completedAtKey = 'completedAt';
  static const longestSuccessfulSpanKey = 'longestSuccessfulSpan';
  static const visualTotalPointsKey = 'visualTotalPoints';
  static const visualRoundsPlayedKey = 'visualRoundsPlayed';

  final String testId;
  final double normalizedScore;
  final DateTime completedAt;
  final int? longestSuccessfulSpan;
  final int? visualTotalPoints;
  final int? visualRoundsPlayed;

  Map<String, dynamic> toJson() => {
        testIdKey: testId,
        normalizedScoreKey: normalizedScore,
        completedAtKey: completedAt.toIso8601String(),
        if (longestSuccessfulSpan != null)
          longestSuccessfulSpanKey: longestSuccessfulSpan,
        if (visualTotalPoints != null)
          visualTotalPointsKey: visualTotalPoints,
        if (visualRoundsPlayed != null)
          visualRoundsPlayedKey: visualRoundsPlayed,
      };

  factory CognitiveTestResult.fromJson(Map<String, dynamic> json) {
    return CognitiveTestResult(
      testId: json[testIdKey] as String? ?? 'unknown',
      normalizedScore: (json[normalizedScoreKey] as num?)?.toDouble() ?? 0,
      completedAt: DateTime.parse(json[completedAtKey] as String),
      longestSuccessfulSpan: json[longestSuccessfulSpanKey] as int?,
      visualTotalPoints: json[visualTotalPointsKey] as int?,
      visualRoundsPlayed: json[visualRoundsPlayedKey] as int?,
    );
  }
}
