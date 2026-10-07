import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/glow_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../brain_check/data/brain_check_completion_provider.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';
import '../application/daily_session_controller.dart';
import '../data/daily_session_controller_provider.dart';
import '../data/home_dashboard_provider.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';
import '../domain/home_dashboard_metrics.dart';
import 'home_dashboard_sections.dart';

const double _kTodayContentBottomClearance = AppDesignConstants.v2PadBottom;
const double _kTodayPadH = AppDesignConstants.v2PadH;
const double _kTodayPadTop = AppDesignConstants.v2PadTop;

/// HOM-01 — one clear action Home.
class TodayHomeScreen extends ConsumerStatefulWidget {
  const TodayHomeScreen({super.key});

  @override
  ConsumerState<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends ConsumerState<TodayHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dailySessionControllerProvider).loadToday(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final controller = ref.watch(dailySessionControllerProvider);
    final prefs = ref.watch(appPreferencesProvider);
    final dashboard = ref.watch(homeDashboardProvider).valueOrNull ??
        HomeDashboardMetrics.empty;
    final brainCheckDone = ref.watch(brainCheckIsCompletedProvider);
    final userName = homeDisplayName(prefs);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: TodayHomeBody(
        loc: loc,
        languageCode: isAr ? 'ar' : 'en',
        loading: controller.loading,
        errorKey: controller.errorKey,
        plan: controller.plan,
        session: controller.session,
        dashboard: dashboard,
        brainCheckCompleted: brainCheckDone,
        userDisplayName: userName,
        onRetry: controller.loadToday,
        onBuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
        onStartBrainCheck: () => context.go(
          V2SetupRecovery.brainCheckLocation(source: 'today'),
        ),
        onPrimary: () => _onPrimary(context, controller),
        onOpenSafa: () => context.go(
          '${AppRoutes.v2Safa}?origin=today&returnTo=${Uri.encodeComponent(AppRoutes.v2Home)}',
        ),
        onOpenWeeklyReport: () => context.go(AppRoutes.v2WeeklyReview),
        onOpenProgress: () => context.go(AppRoutes.v2Progress),
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
    HapticFeedback.lightImpact();
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
    required this.onStartBrainCheck,
    required this.onPrimary,
    required this.onOpenSafa,
    this.dashboard = HomeDashboardMetrics.empty,
    this.brainCheckCompleted = false,
    this.userDisplayName = '',
    this.onOpenWeeklyReport,
    this.onOpenProgress,
    // Legacy params kept for existing tests.
    this.hasProfilePack = false,
    this.selectedDay,
    this.onPreviousDay,
    this.onNextDay,
    this.onReturnToToday,
    this.onViewPlan,
    this.onOpenSuggestedExercise,
    this.onOpenProgramPath,
    this.onOpenWeeklyTest,
    this.onOpenIqTest,
    this.onOpenDigitalBrainRotTest,
    this.onOpenFocusTest,
    this.onOpenMemoryTest,
    this.onOpenTestsCatalog,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final DailySession? session;
  final VoidCallback onRetry;
  final VoidCallback onBuildPlan;
  final VoidCallback onStartBrainCheck;
  final VoidCallback onPrimary;
  final VoidCallback onOpenSafa;
  final HomeDashboardMetrics dashboard;
  final bool brainCheckCompleted;
  final String userDisplayName;
  final VoidCallback? onOpenWeeklyReport;
  final VoidCallback? onOpenProgress;
  final bool hasProfilePack;
  final DateTime? selectedDay;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onReturnToToday;
  final VoidCallback? onViewPlan;
  final VoidCallback? onOpenSuggestedExercise;
  final VoidCallback? onOpenProgramPath;
  final VoidCallback? onOpenWeeklyTest;
  final VoidCallback? onOpenIqTest;
  final VoidCallback? onOpenDigitalBrainRotTest;
  final VoidCallback? onOpenFocusTest;
  final VoidCallback? onOpenMemoryTest;
  final VoidCallback? onOpenTestsCatalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = V2ShellVisual.bodyMuted(theme);

    if (loading) {
      return _HomeSkeleton(loc: loc);
    }

    if (plan == null && errorKey == 'missing_plan') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.v2TodayHomeMissingPlan, style: bodyStyle),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBuildPlan,
                  child: Text(loc.v2TodayHomeCtaStart),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final checkDone = brainCheckCompleted || dashboard.brainCheckCompleted;
    final actTitle = plan == null
        ? loc.v2TodayHomeCtaStart
        : (resolveTodayActTitle(plan!, languageCode) ??
            loc.v2TodayPreviewFallbackTitle);
    final minutes = plan?.dayTemplate.todayPreview.estimatedMinutesMin ?? 3;
    final status = session?.status;
    final ctaLabel = switch (status) {
      DailySessionStatus.inProgress => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.reflecting => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.completed => loc.v2TodayHomeCtaViewCompleted,
      DailySessionStatus.partial => loc.v2TodayHomeCtaContinue,
      _ => loc.homeTodayStepStart,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _kTodayPadH,
        _kTodayPadTop,
        _kTodayPadH,
        _kTodayContentBottomClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HomeGreetingHeader(
                  loc: loc,
                  userName: userDisplayName,
                ),
              ),
              const SizedBox(width: 8),
              _StreakFlame(
                loc: loc,
                streakDays: dashboard.streakDays,
              ),
            ],
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          Text(
            loc.homeProgramDayLabel(
              '${dashboard.programDay}',
              '${dashboard.programTotalDays}',
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          KeyedSubtree(
            key: const Key('home_program_progress'),
            child: GlowProgressBar(
              progress: dashboard.programProgress,
              height: 8,
              color: AppColors.gold,
              trackColor: AppColors.of(context).border,
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          _TodayHeroCard(
            key: const Key('home_today_hero'),
            loc: loc,
            title: actTitle,
            minutesLabel: loc.v2ExercisesMinutes(minutes),
            ctaLabel: ctaLabel,
            onStart: onPrimary,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('home_sos_button'),
              onPressed: onOpenSafa,
              icon: const Icon(Icons.pan_tool_alt_outlined),
              label: Text(loc.homeSosUrgeCta),
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          _LessonPlaceholderCard(loc: loc),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          _RecoveryScoreMiniCard(
            loc: loc,
            percent: dashboard.recoveryPercent,
            onTap: onOpenProgress,
          ),
          if (dashboard.weeklyReportUnlocked) ...[
            const SizedBox(height: AppDesignConstants.v2GapControl),
            HomeWeeklyReportCard(
              loc: loc,
              metrics: dashboard,
              onOpen: onOpenWeeklyReport ?? onOpenProgress ?? () {},
            ),
          ],
          if (!checkDone && dashboard.programDay >= 2) ...[
            const SizedBox(height: AppDesignConstants.v2GapSection),
            Card(
              key: const Key('home_brain_check_offer'),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(loc.homeBrainCheckOfferTitle),
                subtitle: Text(loc.homeBrainCheckOfferBody),
                trailing: const Icon(Icons.chevron_right),
                onTap: onStartBrainCheck,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.loc, required this.streakDays});
  final AppLocalizations loc;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: loc.homeStreakDaysCount('$streakDays'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '$streakDays',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayHeroCard extends StatelessWidget {
  const _TodayHeroCard({
    super.key,
    required this.loc,
    required this.title,
    required this.minutesLabel,
    required this.ctaLabel,
    required this.onStart,
  });

  final AppLocalizations loc;
  final String title;
  final String minutesLabel;
  final String ctaLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: AppColors.of(context).card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        side: BorderSide(color: AppColors.of(context).border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.homeTodayStepHeading,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              minutesLabel,
              style: V2ShellVisual.bodyMuted(theme),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const Key('home_today_start'),
                onPressed: onStart,
                child: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonPlaceholderCard extends StatelessWidget {
  const _LessonPlaceholderCard({required this.loc});
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('home_lesson_card'),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.homeLessonHeading,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.homeLessonPlaceholderBody,
              style: V2ShellVisual.bodyMuted(Theme.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryScoreMiniCard extends StatelessWidget {
  const _RecoveryScoreMiniCard({
    required this.loc,
    required this.percent,
    this.onTap,
  });

  final AppLocalizations loc;
  final int percent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('home_recovery_score_card'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                loc.homeRecoveryScoreLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              '$percent',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.loc});
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: loc.v2TodayHomeLoading,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(height: 28, color: Colors.black12),
          const SizedBox(height: 16),
          Container(height: 8, color: Colors.black12),
          const SizedBox(height: 24),
          Container(height: 160, color: Colors.black12),
          const SizedBox(height: 16),
          Container(height: 48, color: Colors.black12),
        ],
      ),
    );
  }
}
