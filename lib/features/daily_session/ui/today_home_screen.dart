import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/glow_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../daily_program/ui/home_structured_daily_program_section.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';
import '../application/daily_session_controller.dart';
import '../data/daily_session_controller_provider.dart';
import '../data/home_dashboard_provider.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';
import '../domain/daily_session_step_state.dart';
import '../domain/home_dashboard_metrics.dart';
import 'home_dashboard_sections.dart';

/// Clearance below last CTA so Safa cannot sit against the shell [NavigationBar].
const double _kTodayContentBottomClearance = AppDesignConstants.v2PadBottom;

const double _kTodayPadH = AppDesignConstants.v2PadH;
const double _kTodayPadTop = AppDesignConstants.v2PadTop;
const double _kTodayGapActTime = AppDesignConstants.v2GapTight;
const double _kTodayGapTimeStatus = AppDesignConstants.v2GapControl;
const double _kTodayGapStatusCta = AppDesignConstants.v2GapSection;
const double _kTodayGapCtaToSecondary = AppDesignConstants.v2GapMajor;
const double _kTodayGapSecondaryCluster = AppDesignConstants.v2GapInline;

/// HOM-01 — redesigned Home: greeting, recovery, date, streak, pomodoro, program.
class TodayHomeScreen extends ConsumerStatefulWidget {
  const TodayHomeScreen({super.key});

  @override
  ConsumerState<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends ConsumerState<TodayHomeScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    Future.microtask(
      () => ref.read(dailySessionControllerProvider).loadToday(),
    );
  }

  void _shiftDay(int delta) {
    setState(() {
      _selectedDay = _selectedDay.add(Duration(days: delta));
    });
  }

  void _returnToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
    context.go(AppRoutes.v2Home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final controller = ref.watch(dailySessionControllerProvider);
    final prefs = ref.watch(appPreferencesProvider);
    final dashboard = ref.watch(homeDashboardProvider).valueOrNull ??
        HomeDashboardMetrics.empty;
    final userName = homeDisplayName(prefs, loc.v2ProfileDefaultIdentity);

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
        hasProfilePack: controller.hasProfilePack,
        dashboard: dashboard,
        userDisplayName: userName,
        selectedDay: _selectedDay,
        onPreviousDay: () => _shiftDay(-1),
        onNextDay: () => _shiftDay(1),
        onReturnToToday: _returnToToday,
        onRetry: controller.loadToday,
        onBuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
        onStartBrainCheck: () => context.go(
          V2SetupRecovery.brainCheckLocation(source: 'today'),
        ),
        onPrimary: () => _onPrimary(context, controller),
        onViewPlan: () {
          final id = controller.plan?.id;
          if (id == null) return;
          context.go('${AppRoutes.v2PlanReveal}?plan=$id');
        },
        onOpenProgress: () => context.go(AppRoutes.v2Progress),
        onOpenSuggestedExercise: () => context.push(AppRoutes.cognitiveHub),
        onOpenProgramPath: () {
          final id = controller.plan?.id;
          if (id == null) {
            context.go(AppRoutes.v2Progress);
            return;
          }
          context.go('${AppRoutes.v2PlanReveal}?plan=$id');
        },
        onOpenSafa: () => context.go(
          '${AppRoutes.v2Safa}?origin=today&returnTo=${Uri.encodeComponent(AppRoutes.v2Home)}',
        ),
        onOpenWeeklyTest: () => context.go(
          V2SetupRecovery.brainCheckLocation(source: 'weekly'),
        ),
        onOpenWeeklyReport: () => context.go(AppRoutes.v2WeeklyReview),
        onOpenIqTest: () => context.push(AppRoutes.v2IqTest),
        onOpenDigitalBrainRotTest: () =>
            context.push(AppRoutes.v2DigitalBrainRotTest),
        onOpenFocusTest: () => context.push(AppRoutes.cognitiveVisual),
        onOpenMemoryTest: () => context.push(AppRoutes.cognitiveMemory),
        onOpenTestsCatalog: () => context.push(AppRoutes.v2Tests),
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
    required this.onStartBrainCheck,
    this.hasProfilePack = false,
    this.dashboard = HomeDashboardMetrics.empty,
    this.userDisplayName = '',
    this.selectedDay,
    this.onPreviousDay,
    this.onNextDay,
    this.onReturnToToday,
    required this.onPrimary,
    required this.onViewPlan,
    this.onOpenProgress,
    this.onOpenSuggestedExercise,
    this.onOpenProgramPath,
    this.onOpenWeeklyTest,
    this.onOpenWeeklyReport,
    required this.onOpenSafa,
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
  final bool hasProfilePack;
  final HomeDashboardMetrics dashboard;
  final String userDisplayName;
  final DateTime? selectedDay;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onReturnToToday;
  final VoidCallback onPrimary;
  final VoidCallback onViewPlan;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenSuggestedExercise;
  final VoidCallback? onOpenProgramPath;
  final VoidCallback? onOpenWeeklyTest;
  final VoidCallback? onOpenWeeklyReport;
  final VoidCallback onOpenSafa;
  final VoidCallback? onOpenIqTest;
  final VoidCallback? onOpenDigitalBrainRotTest;
  final VoidCallback? onOpenFocusTest;
  final VoidCallback? onOpenMemoryTest;
  final VoidCallback? onOpenTestsCatalog;

  DateTime get _day {
    final now = DateTime.now();
    final raw = selectedDay ?? now;
    return DateTime(raw.year, raw.month, raw.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actStyle = V2ShellVisual.heroTitle(theme);
    final bodyStyle = V2ShellVisual.bodyMuted(theme);
    final timeStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.4,
      fontWeight: FontWeight.w500,
    );
    final secondaryActionStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayHomeLoading,
          child: Text(loc.v2TodayHomeLoading, style: bodyStyle),
        ),
      );
    }

    final hasPlan = plan != null && errorKey == null;
    final brainCheckDone =
        dashboard.brainCheckCompleted || hasProfilePack;
    final badgeMetrics = HomeDashboardMetrics(
      focusPercent: dashboard.focusPercent,
      focusImprovementPercent: dashboard.focusImprovementPercent,
      streakDays: dashboard.streakDays,
      exercisesToday: dashboard.exercisesToday,
      programDay: dashboard.programDay,
      programTotalDays: dashboard.programTotalDays,
      brainCheckCompleted: brainCheckDone,
      brainCheckScore: dashboard.brainCheckScore ??
          (brainCheckDone ? dashboard.recoveryPercent : null),
      daysUntilWeeklyTest: dashboard.daysUntilWeeklyTest,
      daysUntilWeeklyReport: dashboard.daysUntilWeeklyReport,
      weeklyTestUnlocked: dashboard.weeklyTestUnlocked,
      weeklyReportUnlocked: dashboard.weeklyReportUnlocked,
    );
    final isToday = () {
      final now = DateTime.now();
      return _day.year == now.year &&
          _day.month == now.month &&
          _day.day == now.day;
    }();
    final needsBrainCheck = !brainCheckDone &&
        V2SetupRecovery.resolve(
              hasProfilePack: hasProfilePack,
              hasValidPlan: hasPlan,
            ) ==
            V2SetupRecoveryAction.startBrainCheck;

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
          KeyedSubtree(
            key: const Key('home_focus_hero'),
            child: HomeFocusHeroCard(
              loc: loc,
              metrics: dashboard,
              onTap: onOpenProgress ?? () {},
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeDateNavigator(
            loc: loc,
            selectedDay: _day,
            onPrevious: onPreviousDay ?? () {},
            onNext: onNextDay ?? () {},
            onReturnToToday: onReturnToToday ?? () {},
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          HomeGreetingHeader(
            loc: loc,
            userName: userDisplayName.isEmpty
                ? loc.v2ProfileDefaultIdentity
                : userDisplayName,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeStreakCard(loc: loc, streakDays: dashboard.streakDays),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeBaselineTestCard(
            loc: loc,
            metrics: badgeMetrics,
            onOpen: onStartBrainCheck,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeWeeklyTestCard(
            loc: loc,
            metrics: badgeMetrics,
            onOpen: onOpenWeeklyTest ?? onStartBrainCheck,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeWeeklyReportCard(
            loc: loc,
            metrics: badgeMetrics,
            onOpen: onOpenWeeklyReport ?? onOpenProgress ?? () {},
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeQuickTestsRow(
            loc: loc,
            onOpenIq: onOpenIqTest ?? () {},
            onOpenDigitalBrainRot: onOpenDigitalBrainRotTest ?? () {},
            onOpenFocus: onOpenFocusTest ?? onOpenSuggestedExercise ?? () {},
            onOpenMemory: onOpenMemoryTest ?? () {},
            onOpenCatalog: onOpenTestsCatalog ?? onOpenSuggestedExercise ?? () {},
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomePomodoroCard(loc: loc),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          HomeSafaCard(loc: loc, onOpen: onOpenSafa),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          V2SectionLabel(
            isToday ? loc.homeTodaySessionHeading : loc.homePastProgramHeading,
          ),
          const SizedBox(height: AppDesignConstants.v2GapSectionLabel),
          HomeStructuredDailyProgramSection(
            loc: loc,
            selectedDay: _day,
          ),
          if (hasPlan && isToday) ...[
            const SizedBox(height: AppDesignConstants.v2GapControl),
            _buildProgramHero(
              context: context,
              theme: theme,
              actStyle: actStyle,
              timeStyle: timeStyle,
            ),
          ] else if (hasPlan && !isToday) ...[
            const SizedBox(height: AppDesignConstants.v2GapControl),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    resolveTodayActTitle(plan!, languageCode) ??
                        loc.v2TodayPreviewFallbackTitle,
                    style: actStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.recoveryPlanTimeRange(
                      '${plan!.dayTemplate.todayPreview.estimatedMinutesMin}',
                      '${plan!.dayTemplate.todayPreview.estimatedMinutesMax}',
                    ),
                    style: timeStyle,
                  ),
                ],
              ),
            ),
          ] else if (needsBrainCheck && isToday) ...[
            const SizedBox(height: AppDesignConstants.v2GapControl),
            _buildEmptyProgramCard(
              context: context,
              needsBrainCheck: needsBrainCheck,
              bodyStyle: bodyStyle,
            ),
          ],
          const SizedBox(height: _kTodayGapCtaToSecondary),
          if (hasPlan && isToday) ...[
            SizedBox(
              height: AppDesignConstants.minTouchTarget,
              child: OutlinedButton(
                onPressed: onViewPlan,
                style: V2ShellVisual.secondaryOutlined().copyWith(
                  textStyle: WidgetStateProperty.all(secondaryActionStyle),
                ),
                child: Text(loc.v2TodayHomeViewPlan),
              ),
            ),
            const SizedBox(height: _kTodayGapSecondaryCluster),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyProgramCard({
    required BuildContext context,
    required bool needsBrainCheck,
    required TextStyle? bodyStyle,
  }) {
    final theme = Theme.of(context);
    final rebuild = errorKey == 'missing_plan' ||
        errorKey == 'unsupported_plan_version' ||
        errorKey == 'missing_today_act';
    final support = needsBrainCheck
        ? loc.recoveryPlanMissingProfile
        : loc.homeDailyProgramEmptyBody;
    final ctaLabel = needsBrainCheck
        ? loc.v2BrainCheckEntryStart
        : rebuild
            ? loc.recoveryPlanBuildCta
            : loc.homeDailyProgramEmptyCta;

    return KeyedSubtree(
      key: const Key('v2_today_empty_state'),
      child: V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              needsBrainCheck
                  ? loc.recoveryPlanMissing
                  : loc.homeDailyProgramEmptyTitle,
              style: V2ShellVisual.heroTitle(theme),
            ),
            const SizedBox(height: 8),
            Text(support, style: bodyStyle),
            if (!needsBrainCheck) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: AppDesignConstants.minTouchTarget,
                child: FilledButton(
                  key: const Key('v2_today_setup_cta'),
                  onPressed: rebuild ? onBuildPlan : onRetry,
                  style: V2ShellVisual.primaryFilled(),
                  child: Text(ctaLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgramHero({
    required BuildContext context,
    required ThemeData theme,
    required TextStyle? actStyle,
    required TextStyle? timeStyle,
  }) {
    final p = plan!;
    final today = p.dayTemplate.todayPreview;
    final title = resolveTodayActTitle(p, languageCode) ??
        loc.v2TodayPreviewFallbackTitle;
    final timeLabel = loc.recoveryPlanTimeRange(
      '${today.estimatedMinutesMin}',
      '${today.estimatedMinutesMax}',
    );
    final statusLabel = _statusLabel(loc, session);
    final ctaLabel = _ctaLabel(loc, session);
    final resolvedPrimary = _isResolvedPrimary(session);

    return V2HeroCard(
      child: _buildHeroContent(
        context: context,
        loc: loc,
        theme: theme,
        title: title,
        timeLabel: timeLabel,
        statusLabel: statusLabel,
        ctaLabel: ctaLabel,
        resolvedPrimary: resolvedPrimary,
        session: session,
        actStyle: actStyle,
        timeStyle: timeStyle,
        onPrimary: onPrimary,
      ),
    );
  }

  static bool _isResolvedPrimary(DailySession? session) {
    if (session == null) return false;
    return session.status == DailySessionStatus.completed ||
        session.status == DailySessionStatus.partial;
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

  Widget _buildHeroContent({
    required BuildContext context,
    required AppLocalizations loc,
    required ThemeData theme,
    required String title,
    required String timeLabel,
    required String statusLabel,
    required String ctaLabel,
    required bool resolvedPrimary,
    required DailySession? session,
    required TextStyle? actStyle,
    required TextStyle? timeStyle,
    required VoidCallback onPrimary,
  }) {
    final ring = _sessionRing(context, session);
    final heroColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          label: '${loc.v2TodayPreviewActHeading}: $title',
          child: Text(
            title,
            key: const Key('v2_today_act_title'),
            style: actStyle,
          ),
        ),
        const SizedBox(height: _kTodayGapActTime),
        Semantics(
          label: timeLabel,
          child: Text(
            timeLabel,
            key: const Key('v2_today_time'),
            style: timeStyle,
          ),
        ),
        const SizedBox(height: _kTodayGapTimeStatus),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: KeyedSubtree(
            key: const Key('v2_today_status_chip'),
            child: _TodayStatusChip(
              label: statusLabel,
              accent: _statusUsesMintAccent(session),
              semanticLabel: '${loc.v2TodayHomeStatusHeading}: $statusLabel',
            ),
          ),
        ),
        const SizedBox(height: _kTodayGapStatusCta),
        SizedBox(
          height: AppDesignConstants.minTouchTarget,
          child: resolvedPrimary
              ? OutlinedButton(
                  key: const Key('v2_today_primary_cta'),
                  onPressed: onPrimary,
                  style: V2ShellVisual.secondaryOutlined(),
                  child: Text(ctaLabel),
                )
              : FilledButton(
                  key: const Key('v2_today_primary_cta'),
                  onPressed: onPrimary,
                  style: V2ShellVisual.primaryFilled(),
                  child: Text(ctaLabel),
                ),
        ),
      ],
    );

    if (ring == null) return heroColumn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: heroColumn),
        const SizedBox(width: AppDesignConstants.v2GapSection),
        ring,
      ],
    );
  }

  static bool _statusUsesMintAccent(DailySession? session) {
    if (session == null) return false;
    return session.status == DailySessionStatus.inProgress ||
        session.status == DailySessionStatus.reflecting;
  }

  static _SessionRingData? _sessionRingData(DailySession? session) {
    if (session == null || session.steps.isEmpty) return null;
    final total = session.steps.length;

    final completed = session.steps
        .where((s) => s.phase == DailySessionStepPhase.completed)
        .length;

    return switch (session.status) {
      DailySessionStatus.inProgress => _SessionRingData(
          progress: ((completed + 0.35) / total).clamp(0.08, 0.92),
          label: '${session.currentStepIndex + 1}/$total',
        ),
      DailySessionStatus.reflecting => _SessionRingData(
          progress: (completed / total).clamp(0.85, 0.98),
          label: '$completed/$total',
        ),
      DailySessionStatus.completed => _SessionRingData(
          progress: 1.0,
          label: '100%',
        ),
      DailySessionStatus.partial => _SessionRingData(
          progress: (completed / total).clamp(0.2, 0.95),
          label: '$completed/$total',
        ),
      _ => null,
    };
  }

  Widget? _sessionRing(BuildContext context, DailySession? session) {
    final data = _sessionRingData(session);
    if (data == null) return null;

    return Semantics(
      label: data.label,
      child: GlowProgressRing(
        key: const Key('v2_today_session_ring'),
        progress: data.progress,
        size: 104,
        strokeWidth: 10,
        child: Text(
          data.label,
          textAlign: TextAlign.center,
          style: V2ShellVisual.heroMetricValue(Theme.of(context))?.copyWith(
            fontSize: 26,
          ),
        ),
      ),
    );
  }
}

class _SessionRingData {
  const _SessionRingData({required this.progress, required this.label});

  final double progress;
  final String label;
}

/// Status chip — mint border when session is active.
class _TodayStatusChip extends StatelessWidget {
  const _TodayStatusChip({
    required this.label,
    required this.accent,
    this.semanticLabel,
  });

  final String label;
  final bool accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent ? AppColors.primaryDim : AppColors.card,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
          border: Border.all(
            color: accent ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: accent ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
