import 'plan_because.dart';
import 'recovery_plan_versions.dart';

/// User-facing explainability bundle (no evidence IDs).
class RecoveryPlanExplanation {
  const RecoveryPlanExplanation({
    required this.mainFocusEn,
    required this.mainFocusAr,
    required this.whyFitsEn,
    required this.whyFitsAr,
    required this.whyMayChangeEn,
    required this.whyMayChangeAr,
    required this.nonMedicalBoundaryEn,
    required this.nonMedicalBoundaryAr,
    required this.todayBecause,
    this.intensityLineEn,
    this.intensityLineAr,
    this.confidenceLineEn,
    this.confidenceLineAr,
  });

  final String mainFocusEn;
  final String mainFocusAr;
  final String whyFitsEn;
  final String whyFitsAr;
  final String whyMayChangeEn;
  final String whyMayChangeAr;
  final String nonMedicalBoundaryEn;
  final String nonMedicalBoundaryAr;
  final PlanBecause todayBecause;
  final String? intensityLineEn;
  final String? intensityLineAr;
  final String? confidenceLineEn;
  final String? confidenceLineAr;

  String mainFocusForLocale(String languageCode) =>
      languageCode == 'ar' ? mainFocusAr : mainFocusEn;

  String whyFitsForLocale(String languageCode) =>
      languageCode == 'ar' ? whyFitsAr : whyFitsEn;

  String whyMayChangeForLocale(String languageCode) =>
      languageCode == 'ar' ? whyMayChangeAr : whyMayChangeEn;

  String nonMedicalForLocale(String languageCode) =>
      languageCode == 'ar' ? nonMedicalBoundaryAr : nonMedicalBoundaryEn;

  String? intensityLineForLocale(String languageCode) {
    if (languageCode == 'ar') return intensityLineAr;
    return intensityLineEn;
  }

  String? confidenceLineForLocale(String languageCode) {
    if (languageCode == 'ar') return confidenceLineAr;
    return confidenceLineEn;
  }

  /// 1–3 because lines for PLN-01.
  List<String> becauseLinesForLocale(String languageCode) {
    final lines = <String>[todayBecause.forLocale(languageCode)];
    final intensity = intensityLineForLocale(languageCode);
    if (intensity != null && intensity.isNotEmpty) lines.add(intensity);
    final confidence = confidenceLineForLocale(languageCode);
    if (confidence != null && confidence.isNotEmpty) lines.add(confidence);
    return lines;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mainFocusEn': mainFocusEn,
        'mainFocusAr': mainFocusAr,
        'whyFitsEn': whyFitsEn,
        'whyFitsAr': whyFitsAr,
        'whyMayChangeEn': whyMayChangeEn,
        'whyMayChangeAr': whyMayChangeAr,
        'nonMedicalBoundaryEn': nonMedicalBoundaryEn,
        'nonMedicalBoundaryAr': nonMedicalBoundaryAr,
        'todayBecause': todayBecause.toJson(),
        if (intensityLineEn != null) 'intensityLineEn': intensityLineEn,
        if (intensityLineAr != null) 'intensityLineAr': intensityLineAr,
        if (confidenceLineEn != null) 'confidenceLineEn': confidenceLineEn,
        if (confidenceLineAr != null) 'confidenceLineAr': confidenceLineAr,
        'engineVersion': RecoveryPlanVersions.engine,
      };

  factory RecoveryPlanExplanation.fromJson(Map<String, dynamic> json) {
    return RecoveryPlanExplanation(
      mainFocusEn: json['mainFocusEn'] as String? ?? '',
      mainFocusAr: json['mainFocusAr'] as String? ?? '',
      whyFitsEn: json['whyFitsEn'] as String? ?? '',
      whyFitsAr: json['whyFitsAr'] as String? ?? '',
      whyMayChangeEn: json['whyMayChangeEn'] as String? ?? '',
      whyMayChangeAr: json['whyMayChangeAr'] as String? ?? '',
      nonMedicalBoundaryEn: json['nonMedicalBoundaryEn'] as String? ?? '',
      nonMedicalBoundaryAr: json['nonMedicalBoundaryAr'] as String? ?? '',
      todayBecause: PlanBecause.fromJson(
        Map<String, dynamic>.from(json['todayBecause'] as Map? ?? const {}),
      ),
      intensityLineEn: json['intensityLineEn'] as String?,
      intensityLineAr: json['intensityLineAr'] as String?,
      confidenceLineEn: json['confidenceLineEn'] as String?,
      confidenceLineAr: json['confidenceLineAr'] as String?,
    );
  }
}
