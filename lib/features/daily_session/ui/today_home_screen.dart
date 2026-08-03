import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../application/daily_session_controller.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';

/// HOM-01 — calm Today home (one action, not a warehouse).
class TodayHomeScreen extends ConsumerStatefulWidget {
  const TodayHomeScreen({super.key});

  @override
  ConsumerState<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends ConsumerState<TodayHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dailySessionControllerProvider).loadToday());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final controller = ref.watch(dailySessionControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.v2TodayHomeTitle),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: TodayHomeBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: controller.loading,
          errorKey: controller.errorKey,
          plan: controller.plan,
          session: controller.session,
          onRetry: controller.loadToday,
          onBuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
          onPrimary: () => _onPrimary(context, controller),
          onViewPlan: () {
            final id = controller.plan?.id;
            if (id == null) return;
            context.go('${AppRoutes.v2PlanReveal}?plan=$id');
          },
          onOpenSafa: () => context.go(
            '${AppRoutes.v2Safa}?origin=today&returnTo=${Uri.encodeComponent(AppRoutes.v2Home)}',
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimary(
    BuildContext context,
    DailySessionController controller,
  ) async {
    final session = controller.session;
    if (session?.status.isDoneToday == true) {
      context.go(
        '${AppRoutes.v2SessionLeave}?session=${session!.id}&done=1',
      );
      return;
    }
    if (session?.status == DailySessionStatus.inProgress) {
      context.go('${AppRoutes.v2SessionAct}?session=${session!.id}');
      return;
    }
    if (session?.status == DailySessionStatus.reflecting) {
      context.go('${AppRoutes.v2SessionReflect}?session=${session!.id}');
      return;
    }
    final ensured = await controller.ensureSession();
    if (!context.mounted || ensured == null) return;
    context.go('${AppRoutes.v2SessionPrepare}?session=${ensured.id}');
  }
}

class TodayHomeBody extends StatelessWidget {
  const TodayHomeBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.errorKey,
    required this.plan,
    required this.session,
    required this.onRetry,
    required this.onBuildPlan,
    required this.onPrimary,
    required this.onViewPlan,
    required this.onOpenSafa,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final DailySession? session;
  final VoidCallback onRetry;
  final VoidCallback onBuildPlan;
  final VoidCallback onPrimary;
  final VoidCallback onViewPlan;
  final VoidCallback onOpenSafa;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayHomeLoading,
          child: Text(loc.v2TodayHomeLoading),
        ),
      );
    }

    if (errorKey != null || plan == null) {
      final message = switch (errorKey) {
        'missing_plan' => loc.recoveryPlanMissing,
        'unsupported_plan_version' => loc.recoveryPlanUnsupportedVersion,
        'missing_today_act' => loc.v2TodayPreviewMissingAct,
        'persistence_failed' => loc.v2TodayReadyPersistFailed,
        _ => loc.recoveryPlanGenerationError,
      };
      final rebuild = errorKey == 'missing_plan' ||
          errorKey == 'unsupported_plan_version' ||
          errorKey == 'missing_today_act';
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: rebuild ? onBuildPlan : onRetry,
                child: Text(
                  rebuild ? loc.recoveryPlanBuildCta : loc.recoveryPlanRetry,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final p = plan!;
    final today = p.dayTemplate.todayPreview;
    final title =
        resolveTodayActTitle(p, languageCode) ?? loc.v2TodayPreviewFallbackTitle;
    final because = today.because.forLocale(languageCode);
    final timeLabel = loc.recoveryPlanTimeRange(
      '${today.estimatedMinutesMin}',
      '${today.estimatedMinutesMax}',
    );
    final minLabels = resolveTodayMinimumPathLabels(p, languageCode);
    final statusLabel = _statusLabel(loc, session);
    final ctaLabel = _ctaLabel(loc, session);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.v2TodayHomeOrientation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(loc.v2TodayHomeOrientationBody),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            label: '${loc.v2TodayPreviewActHeading}: $title',
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              loc.v2TodayPreviewBecauseHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '${loc.v2TodayPreviewBecauseHeading}: $because',
            child: Text(because),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: timeLabel,
            child: Text(timeLabel),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanMinimumPath,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (minLabels.isEmpty)
            Text(loc.recoveryPlanNoSteps)
          else
            ...minLabels.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(l),
              ),
            ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              loc.recoveryPlanStandardPath,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(loc.v2TodayHomeStandardPathHint),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            label: '${loc.v2TodayHomeStatusHeading}: $statusLabel',
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onPrimary,
              child: Text(ctaLabel),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onViewPlan,
              child: Text(loc.v2TodayHomeViewPlan),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: TextButton(
              key: const Key('v2_today_safa_entry'),
              onPressed: onOpenSafa,
              child: Text(loc.v2SafaEntryToday),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations loc, DailySession? session) {
    if (session == null) return loc.v2TodayHomeStatusReady;
    return switch (session.status) {
      DailySessionStatus.completed => loc.v2TodayHomeStatusDone,
      DailySessionStatus.partial => loc.v2TodayHomeStatusPartial,
      DailySessionStatus.inProgress => loc.v2TodayHomeStatusInProgress,
      DailySessionStatus.reflecting => loc.v2TodayHomeStatusReflect,
      DailySessionStatus.prepared => loc.v2TodayHomeStatusReady,
      _ => loc.v2TodayHomeStatusReady,
    };
  }

  String _ctaLabel(AppLocalizations loc, DailySession? session) {
    if (session == null) return loc.v2TodayHomeCtaStart;
    return switch (session.status) {
      DailySessionStatus.completed => loc.v2TodayHomeCtaViewCompleted,
      DailySessionStatus.inProgress => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.reflecting => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.partial => loc.v2TodayHomeCtaViewCompleted,
      _ => loc.v2TodayHomeCtaStart,
    };
  }
}
