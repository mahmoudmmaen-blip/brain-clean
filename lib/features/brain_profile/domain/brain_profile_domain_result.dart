/// Aggregated result for one reported domain (not a clinical score).
class BrainProfileDomainResult {
  const BrainProfileDomainResult({
    required this.domainId,
    required this.titleEn,
    required this.titleAr,
    required this.answeredCount,
    required this.expectedCount,
    required this.missingQuestionIds,
    this.normalizedMean,
    this.displayScore,
  });

  final String domainId;
  final String titleEn;
  final String titleAr;
  final int answeredCount;
  final int expectedCount;

  /// Internal 0–100 mean (may have fractional precision).
  final double? normalizedMean;

  /// User-facing whole-number domain score when available.
  final int? displayScore;
  final List<String> missingQuestionIds;

  bool get hasData => normalizedMean != null && answeredCount > 0;
  bool get isComplete => missingQuestionIds.isEmpty && answeredCount > 0;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'domainId': domainId,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'answeredCount': answeredCount,
        'expectedCount': expectedCount,
        'missingQuestionIds': missingQuestionIds,
        if (normalizedMean != null) 'normalizedMean': normalizedMean,
        if (displayScore != null) 'displayScore': displayScore,
      };

  factory BrainProfileDomainResult.fromJson(Map<String, dynamic> json) {
    final missing = <String>[];
    final rawMissing = json['missingQuestionIds'];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        missing.add(item.toString());
      }
    }
    final mean = (json['normalizedMean'] as num?)?.toDouble();
    final display = (json['displayScore'] as num?)?.toInt() ??
        (mean == null ? null : (mean + 0.5).floor().clamp(0, 100));
    return BrainProfileDomainResult(
      domainId: json['domainId'] as String,
      titleEn: json['titleEn'] as String? ?? json['domainId'] as String,
      titleAr: json['titleAr'] as String? ?? json['domainId'] as String,
      answeredCount: (json['answeredCount'] as num?)?.toInt() ?? 0,
      expectedCount: (json['expectedCount'] as num?)?.toInt() ?? 0,
      missingQuestionIds: List<String>.unmodifiable(missing),
      normalizedMean: mean,
      displayScore: display,
    );
  }
}
