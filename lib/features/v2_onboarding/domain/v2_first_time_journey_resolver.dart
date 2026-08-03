import '../../../core/constants/app_routes.dart';
import '../../brain_check/domain/brain_check_progress.dart';
import 'v2_onboarding_state.dart';
import 'v2_onboarding_status.dart';
import 'v2_onboarding_step.dart';

/// Snapshot of checkpoints used for V2 first-time journey routing (test entry).
///
/// Does not replace production splash / V1 startup.
class V2FirstTimeJourneySnapshot {
  const V2FirstTimeJourneySnapshot({
    required this.onboarding,
    this.checkProgress,
    this.hasCompletedCheck = false,
    this.hasProfilePack = false,
    this.profileSessionId,
    this.hasActivePlan = false,
    this.activePlanId,
    this.planCorrupt = false,
    this.planUnsupportedVersion = false,
    this.hasTodayAct = true,
  });

  final V2OnboardingState onboarding;
  final BrainCheckProgress? checkProgress;
  final bool hasCompletedCheck;
  final bool hasProfilePack;
  final String? profileSessionId;
  final bool hasActivePlan;
  final String? activePlanId;
  final bool planCorrupt;
  final bool planUnsupportedVersion;
  final bool hasTodayAct;

  bool get hasCheckDraft {
    final p = checkProgress;
    if (p == null) return false;
    return p.hasDraftProgress && !p.isComplete;
  }
}

/// Destinations inside the approved V2 first-time boundary.
enum V2FirstTimeDestination {
  onboarding,
  brainCheckEntry,
  brainCheckBuilding,
  planBuilding,
  planReveal,
  todayPreview,
  todayReady,
  calmRecovery,
}

/// Deterministic returning-user / resume decision for V2 test entry.
class V2FirstTimeRouteDecision {
  const V2FirstTimeRouteDecision({
    required this.destination,
    required this.reason,
    this.planId,
    this.sessionId,
  });

  final V2FirstTimeDestination destination;
  final String reason;
  final String? planId;
  final String? sessionId;

  String get location {
    switch (destination) {
      case V2FirstTimeDestination.onboarding:
        return AppRoutes.v2Onboarding;
      case V2FirstTimeDestination.brainCheckEntry:
        return '${AppRoutes.v2BrainCheckEntry}?mode=lite&source=onboarding';
      case V2FirstTimeDestination.brainCheckBuilding:
        return AppRoutes.v2BrainCheckBuilding;
      case V2FirstTimeDestination.planBuilding:
        return AppRoutes.v2PlanBuilding;
      case V2FirstTimeDestination.planReveal:
        final id = planId;
        if (id != null && id.isNotEmpty) {
          return '${AppRoutes.v2PlanReveal}?plan=$id';
        }
        return AppRoutes.v2PlanReveal;
      case V2FirstTimeDestination.todayPreview:
        final id = planId;
        if (id != null && id.isNotEmpty) {
          return '${AppRoutes.v2PlanTodayPreview}?plan=$id';
        }
        return AppRoutes.v2PlanTodayPreview;
      case V2FirstTimeDestination.todayReady:
        final id = planId;
        if (id != null && id.isNotEmpty) {
          return '${AppRoutes.v2PlanTodayReady}?plan=$id';
        }
        return AppRoutes.v2PlanTodayReady;
      case V2FirstTimeDestination.calmRecovery:
        return AppRoutes.v2Onboarding;
    }
  }
}

/// Pure resolver — no I/O, no production splash mutation.
abstract final class V2FirstTimeJourneyResolver {
  static V2FirstTimeRouteDecision resolve(V2FirstTimeJourneySnapshot snap) {
    final onb = snap.onboarding;
    final planId = snap.activePlanId ?? onb.planId;

    if (onb.isJourneyComplete || onb.status == V2OnboardingStatus.completed) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.todayReady,
        reason: !snap.hasActivePlan
            ? 'missing_plan'
            : snap.planCorrupt
                ? 'corrupt_plan'
                : snap.planUnsupportedVersion
                    ? 'unsupported_plan_version'
                    : !snap.hasTodayAct
                        ? 'missing_today_act'
                        : 'journey_complete',
        planId: planId,
      );
    }

    if (onb.status == V2OnboardingStatus.notStarted ||
        (onb.status == V2OnboardingStatus.inProgress &&
            onb.currentStep.isPreCheckStep)) {
      return const V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.onboarding,
        reason: 'onboarding_in_progress',
      );
    }

    if (snap.hasCheckDraft) {
      return const V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.brainCheckEntry,
        reason: 'brain_check_draft',
      );
    }

    if (snap.hasCompletedCheck && !snap.hasProfilePack) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.brainCheckBuilding,
        reason: 'missing_profile',
        sessionId: snap.profileSessionId ?? onb.profileSessionId,
      );
    }

    if (snap.hasProfilePack && !snap.hasActivePlan) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.planBuilding,
        reason: snap.planCorrupt
            ? 'corrupt_plan'
            : snap.planUnsupportedVersion
                ? 'unsupported_plan_version'
                : 'missing_plan',
      );
    }

    if (onb.todayPreviewed ||
        onb.currentStep == V2OnboardingStep.todayPreview) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.todayReady,
        reason: 'today_preview_done',
        planId: planId,
      );
    }

    if (onb.planRevealed || onb.currentStep == V2OnboardingStep.planReveal) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.todayPreview,
        reason: 'plan_ready_preview',
        planId: planId,
      );
    }

    if (snap.hasActivePlan) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.planReveal,
        reason: 'plan_ready_reveal',
        planId: planId,
      );
    }

    if (onb.profileRevealed ||
        onb.currentStep == V2OnboardingStep.profileReveal) {
      return const V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.planBuilding,
        reason: 'profile_ready',
      );
    }

    if (snap.hasCompletedCheck) {
      return V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.brainCheckBuilding,
        reason: 'check_complete_build_profile',
        sessionId: snap.profileSessionId ?? onb.profileSessionId,
      );
    }

    if (onb.brainCheckReady ||
        onb.status == V2OnboardingStatus.readyForBrainCheck) {
      return const V2FirstTimeRouteDecision(
        destination: V2FirstTimeDestination.brainCheckEntry,
        reason: 'ready_for_brain_check',
      );
    }

    return const V2FirstTimeRouteDecision(
      destination: V2FirstTimeDestination.calmRecovery,
      reason: 'invalid_state',
    );
  }
}
