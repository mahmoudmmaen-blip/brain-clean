import 'package:brain_clean_mobile/core/constants/app_routes.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_ar.dart';
import 'package:brain_clean_mobile/core/l10n/app_localizations_en.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_first_time_journey_resolver.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_state.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_status.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_onboarding_step.dart';
import 'package:brain_clean_mobile/features/v2_onboarding/domain/v2_setup_recovery.dart';
import 'package:brain_clean_mobile/features/v2_shell/domain/v2_shell_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('V2SetupRecovery state matrix', () {
    test('no ProfilePack + no Plan → Start Brain Check', () {
      expect(
        V2SetupRecovery.resolve(
          hasProfilePack: false,
          hasValidPlan: false,
        ),
        V2SetupRecoveryAction.startBrainCheck,
      );
    });

    test('ProfilePack + no Plan → Build Recovery Plan', () {
      expect(
        V2SetupRecovery.resolve(
          hasProfilePack: true,
          hasValidPlan: false,
        ),
        V2SetupRecoveryAction.buildPlan,
      );
    });

    test('valid Plan → loaded Today', () {
      expect(
        V2SetupRecovery.resolve(
          hasProfilePack: true,
          hasValidPlan: true,
        ),
        V2SetupRecoveryAction.showToday,
      );
      expect(
        V2SetupRecovery.resolve(
          hasProfilePack: false,
          hasValidPlan: true,
        ),
        V2SetupRecoveryAction.showToday,
      );
    });

    test('Brain Check location is existing V2 lite Check entry', () {
      expect(
        V2SetupRecovery.brainCheckLocation(source: 'today'),
        '/v2/check?mode=lite&source=today',
      );
      expect(
        V2SetupRecovery.brainCheckLocation(source: 'plan_building'),
        '/v2/check?mode=lite&source=plan_building',
      );
      expect(
        V2SetupRecovery.brainCheckLocation(source: 'profile'),
        '/v2/check?mode=lite&source=profile',
      );
    });

    test('Profile missing pack → Check; pack exists → reveal', () {
      expect(
        V2SetupRecovery.profileBrainActionLocation(hasProfilePack: false),
        '/v2/check?mode=lite&source=profile',
      );
      expect(
        V2SetupRecovery.profileBrainActionLocation(hasProfilePack: true),
        AppRoutes.v2BrainProfile,
      );
    });

    test('EN/AR CTAs name the same Brain Check and Plan actions', () {
      final en = AppLocalizationsEn();
      final ar = AppLocalizationsAr();
      expect(en.v2BrainCheckEntryStart, 'Start Brain Check');
      expect(ar.v2BrainCheckEntryStart, 'ابدأ فحص الدماغ');
      expect(en.recoveryPlanBuildCta, 'Build Recovery Plan');
      expect(ar.recoveryPlanBuildCta, 'ابنِ خطة التعافي');
    });
  });

  group('Brain Check → Profile → Plan handoff', () {
    test('completed check without pack still builds Profile', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        currentStep: V2OnboardingStep.checkIntro,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
        ),
      );
      expect(d.destination, V2FirstTimeDestination.brainCheckBuilding);
      expect(d.location, AppRoutes.v2BrainCheckBuilding);
    });

    test('pack without plan still builds Recovery Plan', () {
      final onb = V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        profileRevealed: true,
        currentStep: V2OnboardingStep.profileReveal,
      );
      final d = V2FirstTimeJourneyResolver.resolve(
        V2FirstTimeJourneySnapshot(
          onboarding: onb,
          hasCompletedCheck: true,
          hasProfilePack: true,
        ),
      );
      expect(d.destination, V2FirstTimeDestination.planBuilding);
      expect(d.location, AppRoutes.v2PlanBuilding);
    });

    test('building screen still hands off to Profile reveal', () {
      expect(AppRoutes.v2BrainCheckBuilding, '/v2/brain-check/building');
      expect(AppRoutes.v2BrainProfile, '/v2/brain-profile');
      expect(AppRoutes.v2PlanBuilding, '/v2/plan/building');
    });
  });

  group('four-tab shell topology', () {
    test('Today Plan Progress Profile unchanged', () {
      expect(V2ShellTab.values, [
        V2ShellTab.today,
        V2ShellTab.plan,
        V2ShellTab.progress,
        V2ShellTab.profile,
      ]);
    });
  });
}
