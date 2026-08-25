import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/glow_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../pomodoro/application/pomodoro_provider.dart';
import '../../pomodoro/domain/pomodoro_logic.dart';
import '../../daily_program/ui/home_structured_daily_program_section.dart'
    show homePomodoroAnchorKey;
import '../data/home_dashboard_provider.dart';
import '../domain/home_dashboard_metrics.dart';

/// Time-based greeting + user name.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.loc,
    required this.userName,
    this.now,
  });

  final AppLocalizations loc;
  final String userName;
  final DateTime? now;

  String _periodLabel(HomeGreetingPeriod period) {
    return switch (period) {
      HomeGreetingPeriod.morning => loc.homeGreetingMorning,
      HomeGreetingPeriod.afternoon => loc.homeGreetingAfternoon,
      HomeGreetingPeriod.evening => loc.homeGreetingEvening,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = homeGreetingPeriodFor(now ?? DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _periodLabel(period),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.of(context).textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            loc.homeGreetingName(userName),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Day navigator: previous / label / next, with return-to-today when offset.
class HomeDateNavigator extends StatelessWidget {
  const HomeDateNavigator({
    super.key,
    required this.loc,
    required this.selectedDay,
    required this.onPrevious,
    required this.onNext,
    required this.onReturnToToday,
  });

  final AppLocalizations loc;
  final DateTime selectedDay;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReturnToToday;

  bool get _isToday {
    final now = DateTime.now();
    return selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;
  }

  bool get _canGoForward {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final next = DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
        .add(const Duration(days: 1));
    return !next.isAfter(DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final label = _isToday
        ? loc.homeDateTodayLabel
        : DateFormat.MMMEd(locale).format(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: AppDesignConstants.minTouchTarget,
              height: AppDesignConstants.minTouchTarget,
              child: IconButton(
                key: const Key('home_date_prev'),
                tooltip: loc.homeDatePrevDay,
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                color: AppColors.of(context).textPrimary,
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: AppDesignConstants.minTouchTarget,
              height: AppDesignConstants.minTouchTarget,
              child: IconButton(
                key: const Key('home_date_next'),
                tooltip: loc.homeDateNextDay,
                onPressed: _canGoForward ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                color: _canGoForward
                    ? AppColors.of(context).textPrimary
                    : AppColors.of(context).textTertiary,
              ),
            ),
          ],
        ),
        if (!_isToday)
          TextButton(
            key: const Key('home_return_today'),
            onPressed: onReturnToToday,
            child: Text(loc.homeReturnToToday),
          ),
      ],
    );
  }
}

/// Recovery % hero — mint metric + progress bar (tappable) + formula info.
class HomeFocusHeroCard extends StatelessWidget {
  const HomeFocusHeroCard({
    super.key,
    required this.loc,
    required this.metrics,
    required this.onTap,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final percent = metrics.recoveryPercent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusHeroCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.card, palette.cardElevated],
            ),
            borderRadius:
                BorderRadius.circular(AppDesignConstants.radiusHeroCard),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDesignConstants.v2HeroPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DecoratedBox(
                              decoration: V2ShellVisual.mintTagDecoration(
                                Theme.of(context),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Text(
                                  loc.homeFocusLevelTag,
                                  style: V2ShellVisual.mintTagLabel(theme),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$percent%',
                                style: V2ShellVisual.heroMetricValue(theme),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                key: const Key('home_recovery_info'),
                                tooltip: loc.homeRecoveryFormulaTitle,
                                onPressed: () => _showRecoveryInfo(context),
                                icon: Icon(
                                  Icons.info_outline,
                                  color: palette.textSecondary,
                                  size: 22,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: AppDesignConstants.minTouchTarget,
                                  minHeight: AppDesignConstants.minTouchTarget,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metrics.focusImprovementPercent > 0
                                ? loc.homeFocusImprovement(
                                    metrics.focusImprovementPercent,
                                  )
                                : loc.homeFocusImprovementPending,
                            style: V2ShellVisual.captionMuted(theme),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: palette.textTertiary),
                  ],
                ),
                const SizedBox(height: 14),
                GlowProgressBar(
                  progress: metrics.focusProgress,
                  height: 7,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecoveryInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.of(ctx).card,
          title: Text(loc.homeRecoveryFormulaTitle),
          content: Text(loc.homeRecoveryFormulaBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.commonOk),
            ),
          ],
        );
      },
    );
  }
}

/// Day streak counter — single prominent metric.
class HomeStreakCard extends StatelessWidget {
  const HomeStreakCard({
    super.key,
    required this.loc,
    required this.streakDays,
  });

  final AppLocalizations loc;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final empty = streakDays <= 0;
    return DecoratedBox(
      key: const Key('home_metric_streak'),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        border: Border.all(color: palette.border),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: empty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.homeStreakMotivation,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.homeMetricStreakStartCta,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$streakDays',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            height: 1.05,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.homeMetricStreakLabel,
                          style: V2ShellVisual.captionMuted(theme),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak + today's exercises quick metrics (kept for older call sites).
class HomeQuickMetricsRow extends StatelessWidget {
  const HomeQuickMetricsRow({
    super.key,
    required this.loc,
    required this.metrics,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return HomeStreakCard(loc: loc, streakDays: metrics.streakDays);
  }
}

/// Embedded Pomodoro — circular ring + chips + start/pause.
class HomePomodoroCard extends ConsumerWidget {
  const HomePomodoroCard({super.key, required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final notifier = ref.read(pomodoroControllerProvider.notifier);
    final timeLabel = DateFormatUtils.countdown(pomodoro.remainingSeconds);
    final running = pomodoro.isRunning;

    return KeyedSubtree(
      key: homePomodoroAnchorKey,
      child: V2InfoCard(
        key: const Key('home_pomodoro_card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.homePomodoroTitle,
                    style: V2ShellVisual.sectionLabel(theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: GlowProgressRing(
                progress: pomodoro.progress,
                size: 168,
                strokeWidth: 10,
                child: Text(
                  timeLabel,
                  textAlign: TextAlign.center,
                  style: V2ShellVisual.heroMetricValue(theme)?.copyWith(
                    fontSize: 36,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _DurationChip(
                  key: const Key('home_pomodoro_minus_5'),
                  label: loc.homePomodoroMinus5,
                  selected: false,
                  enabled: !running &&
                      pomodoro.focusMinutes > kPomodoroFocusMinutesMin,
                  onTap: () =>
                      notifier.adjustFocusMinutes(-kPomodoroFocusMinutesStep),
                ),
                _DurationChip(
                  label: loc.homePomodoroMinutesShort,
                  selected:
                      pomodoro.focusMinutes == kPomodoroFocusMinutesShort,
                  enabled: !running,
                  onTap: () =>
                      notifier.setFocusMinutes(kPomodoroFocusMinutesShort),
                ),
                _DurationChip(
                  label: loc.homePomodoroMinutesLong,
                  selected: pomodoro.focusMinutes == kPomodoroFocusMinutesLong,
                  enabled: !running,
                  onTap: () =>
                      notifier.setFocusMinutes(kPomodoroFocusMinutesLong),
                ),
                _DurationChip(
                  key: const Key('home_pomodoro_plus_5'),
                  label: loc.homePomodoroPlus5,
                  selected: false,
                  enabled: !running &&
                      pomodoro.focusMinutes < kPomodoroFocusMinutesMax,
                  onTap: () =>
                      notifier.adjustFocusMinutes(kPomodoroFocusMinutesStep),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: AppDesignConstants.minTouchTarget,
              child: FilledButton(
                key: const Key('home_pomodoro_primary'),
                onPressed: running ? notifier.pause : notifier.start,
                style: running
                    ? FilledButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: const Color(0xFF1A1400),
                        minimumSize: const Size(
                          AppDesignConstants.minTouchTarget,
                          AppDesignConstants.minTouchTarget,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesignConstants.radiusButton,
                          ),
                        ),
                      )
                    : V2ShellVisual.primaryFilled(),
                child: Text(
                  running ? loc.homePomodoroPause : loc.homePomodoroStart,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: AppDesignConstants.minTouchTarget,
              child: OutlinedButton.icon(
                key: const Key('home_pomodoro_reset'),
                onPressed: notifier.reset,
                style: V2ShellVisual.secondaryOutlined(),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(loc.pomodoroReset),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(
            minHeight: AppDesignConstants.minTouchTarget,
            minWidth: AppDesignConstants.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (enabled ? palette.border : palette.textTertiary),
              width: selected ? 0 : 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppColors.onPrimary
                  : (enabled ? palette.textPrimary : palette.textTertiary),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold/amber badge when Brain Check is incomplete; score card when done.
class HomeBrainCheckBadge extends StatelessWidget {
  const HomeBrainCheckBadge({
    super.key,
    required this.loc,
    required this.metrics,
    required this.onStart,
    this.onRetake,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback onStart;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!metrics.brainCheckCompleted) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('home_brain_check_badge'),
          onTap: onStart,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
              border: Border.all(color: AppColors.gold),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.psychology_alt,
                        color: AppColors.goldText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.homeBrainCheckBadgeTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.goldText,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: AppDesignConstants.minTouchTarget,
                    child: FilledButton(
                      key: const Key('home_brain_check_cta'),
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      child: Text(loc.homeBrainCheckBadgeCta),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final score = metrics.brainCheckScore ?? metrics.recoveryPercent;
    return V2InfoCard(
      key: const Key('home_brain_check_score'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.homeBrainCheckScoreTitle,
                  style: V2ShellVisual.sectionLabel(theme),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.homeBrainCheckScoreValue(score),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.of(context).textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (onRetake != null)
            TextButton(
              onPressed: onRetake,
              child: Text(loc.homeBrainCheckRedo),
            ),
        ],
      ),
    );
  }
}

/// Suggested cognitive exercise — mint accent border, tappable.
class HomeSuggestedExerciseCard extends StatelessWidget {
  const HomeSuggestedExerciseCard({
    super.key,
    required this.loc,
    required this.onTap,
  });

  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.of(context).card,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 42,
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.psychology_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.v2ExercisesNBackTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: DecoratedBox(
                          decoration: V2ShellVisual.mintTagDecoration(Theme.of(context)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            child: Text(
                              loc.homeSuggestedExerciseBadge,
                              style: V2ShellVisual.mintTagLabel(theme),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loc.v2ExercisesNBackSubtitle,
                        style: V2ShellVisual.captionMuted(theme),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                  color: AppColors.of(context).textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 30-day program path progress block.
class HomeProgramPathCard extends StatelessWidget {
  const HomeProgramPathCard({
    super.key,
    required this.loc,
    required this.metrics,
    this.onTap,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = loc.homeProgramPathDay(
      metrics.programDay,
      metrics.programTotalDays,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: V2InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.homeProgramPathTitle,
                style: V2ShellVisual.sectionLabel(theme),
              ),
              const SizedBox(height: 4),
              Text(
                dayLabel,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              GlowProgressBar(
                progress: metrics.programProgress,
                height: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekly cognitive test — locked with 7-day countdown.
class HomeWeeklyTestCard extends StatelessWidget {
  const HomeWeeklyTestCard({
    super.key,
    required this.loc,
    required this.metrics,
    required this.onOpen,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final unlocked = metrics.weeklyTestUnlocked;
    final days = metrics.daysUntilWeeklyTest;
    final subtitle = unlocked
        ? loc.homeWeeklyTestReady
        : (days == null
            ? loc.homeWeeklyTestLocked
            : loc.homeWeeklyTestDaysLeft(days));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home_weekly_test_card'),
        onTap: unlocked ? onOpen : null,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.infoDim,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            border: Border.all(
              color: unlocked
                  ? AppColors.info.withValues(alpha: 0.45)
                  : palette.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDesignConstants.v2InfoPad),
            child: Row(
              children: [
                Icon(
                  unlocked ? Icons.quiz_outlined : Icons.lock_outline,
                  color: unlocked ? AppColors.info : palette.textTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.homeWeeklyTestTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!unlocked)
                  Icon(Icons.lock_outline, color: palette.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Weekly report — locked until cooldown clears; soft unlock pulse when ready.
class HomeWeeklyReportCard extends StatefulWidget {
  const HomeWeeklyReportCard({
    super.key,
    required this.loc,
    required this.metrics,
    required this.onOpen,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback onOpen;

  @override
  State<HomeWeeklyReportCard> createState() => _HomeWeeklyReportCardState();
}

class _HomeWeeklyReportCardState extends State<HomeWeeklyReportCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _unlockPulse;

  @override
  void initState() {
    super.initState();
    _unlockPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.metrics.weeklyReportUnlocked) {
      _unlockPulse.forward();
    }
  }

  @override
  void didUpdateWidget(covariant HomeWeeklyReportCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.metrics.weeklyReportUnlocked &&
        widget.metrics.weeklyReportUnlocked) {
      _unlockPulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _unlockPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final metrics = widget.metrics;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final unlocked = metrics.weeklyReportUnlocked;
    final days = metrics.daysUntilWeeklyReport;
    final subtitle = unlocked
        ? loc.homeWeeklyReportReady
        : (days == null
            ? loc.homeWeeklyReportLocked
            : loc.homeWeeklyReportDaysLeft(days));

    return ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1).animate(
        CurvedAnimation(parent: _unlockPulse, curve: Curves.easeOutBack),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('home_weekly_report_card'),
          onTap: unlocked ? widget.onOpen : null,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(AppDesignConstants.radiusCard),
              border: Border.all(
                color: unlocked
                    ? AppColors.accentPurple.withValues(alpha: 0.45)
                    : palette.border,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDesignConstants.v2InfoPad),
              child: Row(
                children: [
                  Icon(
                    unlocked ? Icons.insights_outlined : Icons.lock_outline,
                    color: unlocked
                        ? AppColors.accentPurple
                        : palette.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          loc.homeWeeklyReportTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked)
                    Icon(Icons.lock_outline, color: palette.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Baseline brain profile — gold when incomplete, score when done.
class HomeBaselineTestCard extends StatelessWidget {
  const HomeBaselineTestCard({
    super.key,
    required this.loc,
    required this.metrics,
    required this.onOpen,
  });

  final AppLocalizations loc;
  final HomeDashboardMetrics metrics;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = metrics.brainCheckCompleted;
    final score = metrics.brainCheckScore;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home_baseline_test_card'),
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: done
                ? AppColors.goldDim.withValues(alpha: 0.55)
                : AppColors.goldDim,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            border: Border.all(
              color: done ? AppColors.gold.withValues(alpha: 0.5) : AppColors.gold,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_alt,
                  color: done ? AppColors.primary : AppColors.goldText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.homeBaselineTestTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color:
                              done ? AppColors.of(context).textPrimary : AppColors.goldText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        done && score != null
                            ? loc.homeBaselineTestScore(score)
                            : loc.homeBaselineTestPending,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              done ? AppColors.of(context).textSecondary : AppColors.goldText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!done)
                  Icon(Icons.workspace_premium, color: AppColors.goldText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prominent Safa entry — same card weight as Pomodoro.
class HomeSafaCard extends StatelessWidget {
  const HomeSafaCard({
    super.key,
    required this.loc,
    required this.onOpen,
  });

  final AppLocalizations loc;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return V2InfoCard(
      key: const Key('home_safa_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accentPink,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.homeSafaCardTitle,
                  style: V2ShellVisual.sectionLabel(theme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.homeSafaCardBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.of(context).textSecondary,
              height: 1.4,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: FilledButton(
              key: const Key('v2_today_safa_entry'),
              onPressed: onOpen,
              style: V2ShellVisual.primaryFilled(),
              child: Text(loc.homeSafaCardCta),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase 5 quick-access chips: IQ, digital brain rot, focus, memory, catalog.
class HomeQuickTestsRow extends StatelessWidget {
  const HomeQuickTestsRow({
    super.key,
    required this.loc,
    required this.onOpenIq,
    required this.onOpenDigitalBrainRot,
    required this.onOpenFocus,
    required this.onOpenMemory,
    required this.onOpenCatalog,
  });

  final AppLocalizations loc;
  final VoidCallback onOpenIq;
  final VoidCallback onOpenDigitalBrainRot;
  final VoidCallback onOpenFocus;
  final VoidCallback onOpenMemory;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home_quick_tests_row'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.homeQuickTestsHeading,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.3,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: AppDesignConstants.v2GapSectionLabel),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickTestChip(
                label: loc.homeQuickTestIq,
                icon: Icons.psychology_outlined,
                accent: AppColors.accentPurple,
                onTap: onOpenIq,
              ),
              _QuickTestChip(
                label: loc.homeQuickTestDigitalBrainRot,
                icon: Icons.smartphone_outlined,
                accent: AppColors.danger,
                onTap: onOpenDigitalBrainRot,
              ),
              _QuickTestChip(
                label: loc.homeQuickTestFocus,
                icon: Icons.visibility_outlined,
                accent: AppColors.primary,
                onTap: onOpenFocus,
              ),
              _QuickTestChip(
                label: loc.homeQuickTestMemory,
                icon: Icons.memory_outlined,
                accent: AppColors.info,
                onTap: onOpenMemory,
              ),
              _QuickTestChip(
                label: loc.homeQuickTestAll,
                icon: Icons.grid_view_outlined,
                accent: AppColors.accentOrange,
                onTap: onOpenCatalog,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickTestChip extends StatelessWidget {
  const _QuickTestChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppDesignConstants.minTouchTarget,
                minWidth: AppDesignConstants.minTouchTarget,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: accent),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
