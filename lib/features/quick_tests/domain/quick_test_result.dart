/// Persisted outcome of a Phase 5 quick test (JSON in app_meta — not Hive typed).
class QuickTestResult {
  const QuickTestResult({
    required this.testId,
    required this.scorePercent,
    required this.completedAt,
    this.correctCount,
    this.totalCount,
  });

  final String testId;

  /// 0–100 wellness / performance score (higher = better for recovery blend).
  final int scorePercent;
  final DateTime completedAt;
  final int? correctCount;
  final int? totalCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'testId': testId,
        'scorePercent': scorePercent,
        'completedAt': completedAt.toUtc().toIso8601String(),
        if (correctCount != null) 'correctCount': correctCount,
        if (totalCount != null) 'totalCount': totalCount,
      };

  factory QuickTestResult.fromJson(Map<String, dynamic> json) {
    return QuickTestResult(
      testId: json['testId'] as String? ?? '',
      scorePercent: (json['scorePercent'] as num?)?.round().clamp(0, 100) ?? 0,
      completedAt: DateTime.parse(json['completedAt'] as String).toUtc(),
      correctCount: (json['correctCount'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
    );
  }
}
