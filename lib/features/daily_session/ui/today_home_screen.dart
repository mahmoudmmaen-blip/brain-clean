import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/glow_progress.dart';
import '../../../core/theme/app_color_theme.dart';
import '../../../core/theme/app_color_theme_provider.dart';
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
      floatingActionButton: FloatingActionButton(
        key: const Key('debug_theme_cycle_fab'),
        tooltip: 'Cycle theme',
        onPressed: () {
          final current = ref.read(selectedColorThemeProvider);
          const all = AppColorTheme.values;
          final next = all[(all.indexOf(current) + 1) % all.length];
          ref.read(selectedColorThemeProvider.notifier).select(next);
        },
        child: const Icon(Icons.palette),
      ),
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
        onOpenDigitalBrainRotTest: () => context.push(AppRoutes.v2BriTest),
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
    final bodyStyle = V2ShellVisual.bodyMuted(theme);

    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayHomeLoading,
          child: Text(loc.v2TodayHomeLoading, style: bodyStyle),
        ),
      );
    }

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
            emphasized: true,
          ),
          const SizedBox(height: AppDesignConstants.v2GapSectionLabel),
          HomeStructuredDailyProgramSection(
            loc: loc,
            selectedDay: _day,
          ),
          const SizedBox(height: _kTodayGapCtaToSecondary),
        ],
      ),
    );
  }
}
