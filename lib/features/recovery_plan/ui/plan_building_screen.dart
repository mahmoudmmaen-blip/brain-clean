import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';
import '../data/recovery_plan_repository_provider.dart';
import '../domain/recovery_plan.dart';
import '../domain/recovery_plan_status.dart';

/// PLN-00 — build Recovery Plan from current ProfilePack.
class PlanBuildingScreen extends ConsumerStatefulWidget {
  const PlanBuildingScreen({super.key});

  @override
  ConsumerState<PlanBuildingScreen> createState() => _PlanBuildingScreenState();
}

class _PlanBuildingScreenState extends ConsumerState<PlanBuildingScreen> {
  var _loading = true;
  String? _errorKey;
  RecoveryPlan? _plan;

  @override
  void initState() {
    super.initState();
    Future.microtask(_build);
  }

  Future<void> _build() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorKey = null;
    });
    try {
      final generator = ref.read(recoveryPlanGeneratorProvider);
      final pack = await generator.latestProfile();
      if (pack == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorKey = 'missing_profile';
        });
        return;
      }
      final plan = await generator.generateFor(pack);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      context.go('${AppRoutes.v2PlanReveal}?plan=${plan.id}');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorKey = 'generation_error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PlanBuildingBody(
          loc: loc,
          loading: _loading,
          errorKey: _errorKey,
          plan: _plan,
          onRetry: _build,
          onStartBrainCheck: () => context.go(
            V2SetupRecovery.brainCheckLocation(source: 'plan_building'),
          ),
          onGoHome: () => context.go(StartupDestination.resolve()),
        ),
      ),
    );
  }
}

/// Sync-testable PLN-00 body.
class PlanBuildingBody extends StatelessWidget {
  const PlanBuildingBody({
    super.key,
    required this.loc,
    required this.loading,
    required this.errorKey,
    required this.plan,
    required this.onRetry,
    required this.onStartBrainCheck,
    required this.onGoHome,
  });

  final AppLocalizations loc;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final VoidCallback onRetry;
  final VoidCallback onStartBrainCheck;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.recoveryPlanBuilding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                loc.recoveryPlanBuilding,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (errorKey != null) {
      final missingProfile = errorKey == 'missing_profile';
      final message = switch (errorKey) {
        'missing_profile' => loc.recoveryPlanMissingProfile,
        'score_unavailable' => loc.recoveryPlanScoreUnavailable,
        'unsupported_version' => loc.recoveryPlanUnsupportedVersion,
        _ => loc.recoveryPlanGenerationError,
      };
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('v2_plan_building_primary_cta'),
                onPressed: missingProfile ? onStartBrainCheck : onRetry,
                child: Text(
                  missingProfile
                      ? loc.v2BrainCheckEntryStart
                      : loc.recoveryPlanRetry,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onGoHome,
                child: Text(loc.recoveryPlanGoHome),
              ),
            ),
          ],
        ),
      );
    }

    final isStarter =
        plan?.generationStatus == RecoveryPlanStatus.starterFallback;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: isStarter ? loc.recoveryPlanStarterReady : loc.recoveryPlanReady,
        child: Text(
          isStarter ? loc.recoveryPlanStarterReady : loc.recoveryPlanReady,
        ),
      ),
    );
  }
}
