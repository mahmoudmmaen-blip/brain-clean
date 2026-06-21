/// Placeholder result for visual / memory cognitive modules.
///
/// Future implementations blend [normalizedScore] into brain performance
/// via [CognitiveTestScorer] and [BhiPillarFrozenSnapshot].
class CognitiveTestResult {
  const CognitiveTestResult({
    required this.testId,
    required this.normalizedScore,
    required this.completedAt,
  });

  static const testIdKey = 'testId';
  static const normalizedScoreKey = 'normalizedScore';
  static const completedAtKey = 'completedAt';

  final String testId;
  final double normalizedScore;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        testIdKey: testId,
        normalizedScoreKey: normalizedScore,
        completedAtKey: completedAt.toIso8601String(),
      };

  factory CognitiveTestResult.fromJson(Map<String, dynamic> json) {
    return CognitiveTestResult(
      testId: json[testIdKey] as String? ?? 'unknown',
      normalizedScore: (json[normalizedScoreKey] as num?)?.toDouble() ?? 0,
      completedAt: DateTime.parse(json[completedAtKey] as String),
    );
  }
}
