import 'v2_onboarding_progress.dart';
import 'v2_onboarding_status.dart';
import 'v2_onboarding_step.dart';
import 'v2_onboarding_version.dart';

/// Local-first V2 onboarding state (no free-text, no remote).
class V2OnboardingState {
  const V2OnboardingState({
    required this.status,
    required this.currentStep,
    required this.createdAt,
    required this.updatedAt,
    required this.schemaVersion,
    this.languageCode,
    this.consentNonMedical = false,
    this.consentTerms = false,
    this.consentAnalyticsOptIn = false,
    this.privacyAcknowledged = false,
    this.ritualWindow,
    this.brainCheckReady = false,
    this.profileRevealed = false,
    this.profileSessionId,
    this.planRevealed = false,
    this.planId,
    this.todayPreviewed = false,
    this.journeyCompletedAt,
  });

  final V2OnboardingStatus status;
  final V2OnboardingStep currentStep;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String schemaVersion;
  final String? languageCode;
  final bool consentNonMedical;
  final bool consentTerms;
  final bool consentAnalyticsOptIn;
  final bool privacyAcknowledged;
  final V2RitualWindow? ritualWindow;
  final bool brainCheckReady;

  /// ONB-07 milestone reached (Profile reveal shown for a session).
  final bool profileRevealed;
  final String? profileSessionId;

  /// ONB-08 milestone — Plan reveal shown.
  final bool planRevealed;
  final String? planId;

  /// ONB-09 milestone — Today preview shown.
  final bool todayPreviewed;

  /// ONB-10 completion timestamp (null until journey closed).
  final DateTime? journeyCompletedAt;

  V2OnboardingProgress get progress => V2OnboardingProgress(
        currentStepIndex: currentStep.orderIndex,
        totalSteps: V2OnboardingStepX.preCheckOrdered.length,
      );

  bool get canSubmitConsent => consentNonMedical && consentTerms;

  bool get isTerminalReady =>
      status == V2OnboardingStatus.readyForBrainCheck ||
      status == V2OnboardingStatus.completed;

  bool get isJourneyComplete =>
      status == V2OnboardingStatus.completed && journeyCompletedAt != null;

  static V2OnboardingState fresh({DateTime? now, String? languageCode}) {
    final t = (now ?? DateTime.now()).toUtc();
    return V2OnboardingState(
      status: V2OnboardingStatus.notStarted,
      currentStep: V2OnboardingStep.welcome,
      createdAt: t,
      updatedAt: t,
      schemaVersion: V2OnboardingVersion.schema,
      languageCode: languageCode,
    );
  }

  V2OnboardingState copyWith({
    V2OnboardingStatus? status,
    V2OnboardingStep? currentStep,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? schemaVersion,
    String? languageCode,
    bool clearLanguage = false,
    bool? consentNonMedical,
    bool? consentTerms,
    bool? consentAnalyticsOptIn,
    bool? privacyAcknowledged,
    V2RitualWindow? ritualWindow,
    bool clearRitual = false,
    bool? brainCheckReady,
    bool? profileRevealed,
    String? profileSessionId,
    bool clearProfileSession = false,
    bool? planRevealed,
    String? planId,
    bool clearPlanId = false,
    bool? todayPreviewed,
    DateTime? journeyCompletedAt,
    bool clearJourneyCompletedAt = false,
  }) {
    return V2OnboardingState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      languageCode:
          clearLanguage ? null : (languageCode ?? this.languageCode),
      consentNonMedical: consentNonMedical ?? this.consentNonMedical,
      consentTerms: consentTerms ?? this.consentTerms,
      consentAnalyticsOptIn:
          consentAnalyticsOptIn ?? this.consentAnalyticsOptIn,
      privacyAcknowledged: privacyAcknowledged ?? this.privacyAcknowledged,
      ritualWindow: clearRitual ? null : (ritualWindow ?? this.ritualWindow),
      brainCheckReady: brainCheckReady ?? this.brainCheckReady,
      profileRevealed: profileRevealed ?? this.profileRevealed,
      profileSessionId: clearProfileSession
          ? null
          : (profileSessionId ?? this.profileSessionId),
      planRevealed: planRevealed ?? this.planRevealed,
      planId: clearPlanId ? null : (planId ?? this.planId),
      todayPreviewed: todayPreviewed ?? this.todayPreviewed,
      journeyCompletedAt: clearJourneyCompletedAt
          ? null
          : (journeyCompletedAt ?? this.journeyCompletedAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status.wireName,
        'currentStep': currentStep.wireName,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'schemaVersion': schemaVersion,
        if (languageCode != null) 'languageCode': languageCode,
        'consentNonMedical': consentNonMedical,
        'consentTerms': consentTerms,
        'consentAnalyticsOptIn': consentAnalyticsOptIn,
        'privacyAcknowledged': privacyAcknowledged,
        if (ritualWindow != null) 'ritualWindow': ritualWindow!.wireName,
        'brainCheckReady': brainCheckReady,
        'profileRevealed': profileRevealed,
        if (profileSessionId != null) 'profileSessionId': profileSessionId,
        'planRevealed': planRevealed,
        if (planId != null) 'planId': planId,
        'todayPreviewed': todayPreviewed,
        if (journeyCompletedAt != null)
          'journeyCompletedAt': journeyCompletedAt!.toUtc().toIso8601String(),
      };

  factory V2OnboardingState.fromJson(Map<String, dynamic> json) {
    final schema = json['schemaVersion'] as String?;
    if (schema != null && schema != V2OnboardingVersion.schema) {
      throw FormatException('unsupported_onboarding_schema:$schema');
    }
    final ritual = V2RitualWindowX.fromWire(json['ritualWindow'] as String?);
    return V2OnboardingState(
      status: V2OnboardingStatusX.fromWire(json['status'] as String?),
      currentStep: V2OnboardingStepX.fromWire(json['currentStep'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')
              ?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      schemaVersion: schema ?? V2OnboardingVersion.schema,
      languageCode: json['languageCode'] as String?,
      consentNonMedical: json['consentNonMedical'] as bool? ?? false,
      consentTerms: json['consentTerms'] as bool? ?? false,
      consentAnalyticsOptIn: json['consentAnalyticsOptIn'] as bool? ?? false,
      privacyAcknowledged: json['privacyAcknowledged'] as bool? ?? false,
      ritualWindow: ritual,
      brainCheckReady: json['brainCheckReady'] as bool? ?? false,
      profileRevealed: json['profileRevealed'] as bool? ?? false,
      profileSessionId: json['profileSessionId'] as String?,
      planRevealed: json['planRevealed'] as bool? ?? false,
      planId: json['planId'] as String?,
      todayPreviewed: json['todayPreviewed'] as bool? ?? false,
      journeyCompletedAt:
          DateTime.tryParse(json['journeyCompletedAt'] as String? ?? '')
              ?.toUtc(),
    );
  }
}
