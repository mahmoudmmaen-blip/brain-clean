import 'recovery_practice_catalog.dart';

/// One practice instance bound to a domain reason.
class RecoveryPlanStep {
  const RecoveryPlanStep({
    required this.stepId,
    required this.practiceId,
    required this.practiceVersion,
    required this.targetDomainId,
    required this.optional,
    required this.nameEn,
    required this.nameAr,
    required this.purposeEn,
    required this.purposeAr,
    required this.minimumPathEn,
    required this.minimumPathAr,
    required this.standardPathEn,
    required this.standardPathAr,
    required this.durationMinutesMin,
    required this.durationMinutesMax,
    required this.accessibilityAltEn,
    required this.accessibilityAltAr,
    required this.completionRule,
    required this.skipBehavior,
    required this.safetyBoundaryEn,
    required this.safetyBoundaryAr,
    required this.becauseTemplateKey,
  });

  final String stepId;
  final String practiceId;
  final String practiceVersion;
  final String targetDomainId;
  final bool optional;
  final String nameEn;
  final String nameAr;
  final String purposeEn;
  final String purposeAr;
  final String minimumPathEn;
  final String minimumPathAr;
  final String standardPathEn;
  final String standardPathAr;
  final int durationMinutesMin;
  final int durationMinutesMax;
  final String accessibilityAltEn;
  final String accessibilityAltAr;
  final String completionRule;
  final String skipBehavior;
  final String safetyBoundaryEn;
  final String safetyBoundaryAr;
  final String becauseTemplateKey;

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

  factory RecoveryPlanStep.fromPractice({
    required String practiceId,
    required String targetDomainId,
    required bool optional,
  }) {
    final practice = RecoveryPracticeCatalog.byId(practiceId);
    return RecoveryPlanStep(
      stepId: 'step_${practiceId}_$targetDomainId',
      practiceId: practiceId,
      practiceVersion: practice.version,
      targetDomainId: targetDomainId,
      optional: optional,
      nameEn: practice.nameEn,
      nameAr: practice.nameAr,
      purposeEn: practice.purposeEn,
      purposeAr: practice.purposeAr,
      minimumPathEn: practice.minimumPathEn,
      minimumPathAr: practice.minimumPathAr,
      standardPathEn: practice.standardPathEn,
      standardPathAr: practice.standardPathAr,
      durationMinutesMin: practice.durationMinutesMin,
      durationMinutesMax: practice.durationMinutesMax,
      accessibilityAltEn: practice.accessibilityAltEn,
      accessibilityAltAr: practice.accessibilityAltAr,
      completionRule: practice.completionRule,
      skipBehavior: practice.skipBehavior,
      safetyBoundaryEn: practice.safetyBoundaryEn,
      safetyBoundaryAr: practice.safetyBoundaryAr,
      becauseTemplateKey: practice.becauseTemplateKey,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stepId': stepId,
        'practiceId': practiceId,
        'practiceVersion': practiceVersion,
        'targetDomainId': targetDomainId,
        'optional': optional,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'purposeEn': purposeEn,
        'purposeAr': purposeAr,
        'minimumPathEn': minimumPathEn,
        'minimumPathAr': minimumPathAr,
        'standardPathEn': standardPathEn,
        'standardPathAr': standardPathAr,
        'durationMinutesMin': durationMinutesMin,
        'durationMinutesMax': durationMinutesMax,
        'accessibilityAltEn': accessibilityAltEn,
        'accessibilityAltAr': accessibilityAltAr,
        'completionRule': completionRule,
        'skipBehavior': skipBehavior,
        'safetyBoundaryEn': safetyBoundaryEn,
        'safetyBoundaryAr': safetyBoundaryAr,
        'becauseTemplateKey': becauseTemplateKey,
      };

  factory RecoveryPlanStep.fromJson(Map<String, dynamic> json) {
    return RecoveryPlanStep(
      stepId: json['stepId'] as String,
      practiceId: json['practiceId'] as String,
      practiceVersion: json['practiceVersion'] as String? ?? '1',
      targetDomainId: json['targetDomainId'] as String? ?? '',
      optional: json['optional'] as bool? ?? false,
      nameEn: json['nameEn'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      purposeEn: json['purposeEn'] as String? ?? '',
      purposeAr: json['purposeAr'] as String? ?? '',
      minimumPathEn: json['minimumPathEn'] as String? ?? '',
      minimumPathAr: json['minimumPathAr'] as String? ?? '',
      standardPathEn: json['standardPathEn'] as String? ?? '',
      standardPathAr: json['standardPathAr'] as String? ?? '',
      durationMinutesMin: (json['durationMinutesMin'] as num?)?.toInt() ?? 1,
      durationMinutesMax: (json['durationMinutesMax'] as num?)?.toInt() ?? 5,
      accessibilityAltEn: json['accessibilityAltEn'] as String? ?? '',
      accessibilityAltAr: json['accessibilityAltAr'] as String? ?? '',
      completionRule: json['completionRule'] as String? ??
          RecoveryPracticeCatalog.completionRule,
      skipBehavior: json['skipBehavior'] as String? ??
          RecoveryPracticeCatalog.skipBehavior,
      safetyBoundaryEn: json['safetyBoundaryEn'] as String? ?? '',
      safetyBoundaryAr: json['safetyBoundaryAr'] as String? ?? '',
      becauseTemplateKey:
          json['becauseTemplateKey'] as String? ?? 'because_priority',
    );
  }
}
