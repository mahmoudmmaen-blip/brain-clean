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
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            loc.homeGreetingName(userName),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
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
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
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
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
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

/// Recovery % hero — mint metric + progress bar (tappable).
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
    final percent = metrics.recoveryPercent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusHeroCard),
        child: V2HeroCard(
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
                            decoration: V2ShellVisual.mintTagDecoration(Theme.of(context)),
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
                        Text(
                          '$percent%',
                          style: V2ShellVisual.heroMetricValue(theme),
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
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
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
    return V2InfoCard(
      key: const Key('home_metric_streak'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.05,
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

/// Embedded Pomodoro — start / pause / reset + 25/50 duration chips.
class HomePomodoroCard extends ConsumerWidget {
  const HomePomodoroCard({super.key, required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final notifier = ref.read(pomodoroControllerProvider.notifier);
    final timeLabel = DateFormatUtils.countdown(pomodoro.remainingSeconds);

    return V2InfoCard(
      key: const Key('home_pomodoro_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.homePomodoroTitle,
            style: V2ShellVisual.sectionLabel(theme),
          ),
          const SizedBox(height: 12),
          Text(
            timeLabel,
            textAlign: TextAlign.center,
            style: V2ShellVisual.heroMetricValue(theme)?.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 10),
          GlowProgressBar(progress: pomodoro.progress, height: 6),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DurationChip(
                label: loc.homePomodoroMinutesShort,
                selected: pomodoro.focusMinutes == kPomodoroFocusMinutesShort,
                enabled: !pomodoro.isRunning,
                onTap: () =>
                    notifier.setFocusMinutes(kPomodoroFocusMinutesShort),
              ),
              _DurationChip(
                label: loc.homePomodoroMinutesLong,
                selected: pomodoro.focusMinutes == kPomodoroFocusMinutesLong,
                enabled: !pomodoro.isRunning,
                onTap: () =>
                    notifier.setFocusMinutes(kPomodoroFocusMinutesLong),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: AppDesignConstants.minTouchTarget,
            child: FilledButton(
              key: const Key('home_pomodoro_primary'),
              onPressed: pomodoro.isRunning ? notifier.pause : notifier.start,
              style: V2ShellVisual.primaryFilled(),
              child: Text(
                pomodoro.isRunning
                    ? loc.homePomodoroPause
                    : loc.homePomodoroStart,
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
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDim : AppColors.cardSecondary,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
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
                    color: AppColors.textPrimary,
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
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
              border: const BorderDirectional(
                start: BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: AppColors.textPrimary,
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
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
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
