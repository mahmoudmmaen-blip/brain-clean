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
  });

  final String domainId;
  final String titleEn;
  final String titleAr;
  final int answeredCount;
  final int expectedCount;

  /// 0–100 equal-weight mean of answered items in this domain, or null if none.
  final double? normalizedMean;
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
      };

  factory BrainProfileDomainResult.fromJson(Map<String, dynamic> json) {
    final missing = <String>[];
    final rawMissing = json['missingQuestionIds'];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        missing.add(item.toString());
      }
    }
    return BrainProfileDomainResult(
      domainId: json['domainId'] as String,
      titleEn: json['titleEn'] as String? ?? json['domainId'] as String,
      titleAr: json['titleAr'] as String? ?? json['domainId'] as String,
      answeredCount: (json['answeredCount'] as num?)?.toInt() ?? 0,
      expectedCount: (json['expectedCount'] as num?)?.toInt() ?? 0,
      missingQuestionIds: List<String>.unmodifiable(missing),
      normalizedMean: (json['normalizedMean'] as num?)?.toDouble(),
    );
  }
}
