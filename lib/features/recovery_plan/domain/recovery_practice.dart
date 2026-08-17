/// Evidence class — never shown in UI (contract §10).
enum PracticeEvidenceClass {
  fact,
  inference,
  hypothesis,
  unknown,
}

extension PracticeEvidenceClassX on PracticeEvidenceClass {
  String get wireName => name;

  static PracticeEvidenceClass fromWire(String? raw) {
    switch (raw) {
      case 'fact':
        return PracticeEvidenceClass.fact;
      case 'inference':
        return PracticeEvidenceClass.inference;
      case 'unknown':
        return PracticeEvidenceClass.unknown;
      case 'hypothesis':
      default:
        return PracticeEvidenceClass.hypothesis;
    }
  }
}

/// One approved V2 recovery practice (catalog entry).
class RecoveryPractice {
  const RecoveryPractice({
    required this.id,
    required this.version,
    required this.nameEn,
    required this.nameAr,
    required this.targetDomainTags,
    required this.purposeEn,
    required this.purposeAr,
    required this.minimumPathEn,
    required this.minimumPathAr,
    required this.standardPathEn,
    required this.standardPathAr,
    required this.durationMinutesMin,
    required this.durationMinutesMax,
    required this.completionRule,
    required this.skipBehavior,
    required this.accessibilityAltEn,
    required this.accessibilityAltAr,
    required this.offline,
    required this.starterOnly,
    required this.safetyBoundaryEn,
    required this.safetyBoundaryAr,
    required this.becauseTemplateKey,
    required this.evidenceClass,
    required this.prohibitedClaims,
  });

  final String id;
  final String version;
  final String nameEn;
  final String nameAr;
  final List<String> targetDomainTags;
  final String purposeEn;
  final String purposeAr;
  final String minimumPathEn;
  final String minimumPathAr;
  final String standardPathEn;
  final String standardPathAr;
  final int durationMinutesMin;
  final int durationMinutesMax;
  final String completionRule;
  final String skipBehavior;
  final String accessibilityAltEn;
  final String accessibilityAltAr;
  final bool offline;
  final bool starterOnly;
  final String safetyBoundaryEn;
  final String safetyBoundaryAr;
  final String becauseTemplateKey;
  final PracticeEvidenceClass evidenceClass;
  final List<String> prohibitedClaims;

  String nameForLocale(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  String purposeForLocale(String languageCode) =>
      languageCode == 'ar' ? purposeAr : purposeEn;

  String minimumPathForLocale(String languageCode) =>
      languageCode == 'ar' ? minimumPathAr : minimumPathEn;

  String standardPathForLocale(String languageCode) =>
      languageCode == 'ar' ? standardPathAr : standardPathEn;

  String accessibilityAltForLocale(String languageCode) =>
      languageCode == 'ar' ? accessibilityAltAr : accessibilityAltEn;

  int get estimatedMinutesMid =>
      ((durationMinutesMin + durationMinutesMax) / 2).round();
}
