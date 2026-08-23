import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../application/structured_daily_program_provider.dart';
import '../domain/daily_program_activity_kind.dart';
import '../domain/structured_daily_activity.dart';
import '../domain/structured_daily_activity_l10n.dart';

/// Scroll target for Home Pomodoro card (daily program deep-link).
final homePomodoroAnchorKey = GlobalKey(debugLabel: 'home_pomodoro_anchor');

/// Checkable structured daily program cards for Home.
class HomeStructuredDailyProgramSection extends ConsumerWidget {
  const HomeStructuredDailyProgramSection({
    super.key,
    required this.loc,
    required this.selectedDay,
  });

  final AppLocalizations loc;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(structuredDailyProgramForDayProvider(selectedDay));
    final palette = AppColors.of(context);

    return async.when(
      loading: () => V2InfoCard(
        child: Text(
          loc.v2TodayHomeLoading,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      error: (_, __) => V2InfoCard(
        child: Text(
          loc.homeDailyProgramEmptyBody,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      data: (view) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (view.showTestsBanner) ...[
              _TestsMotivationBanner(loc: loc),
              const SizedBox(height: AppDesignConstants.v2GapControl),
            ],
            if (view.activities.isEmpty)
              V2InfoCard(
                child: Text(
                  loc.homeDailyProgramEmptyBody,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (final activity in view.activities) ...[
                _ActivityCheckCard(
                  loc: loc,
                  activity: activity,
                  selectedDay: selectedDay,
                  onToggle: (value) {
                    ref.read(structuredDailyProgramControllerProvider).toggle(
                          day: selectedDay,
                          activityId: activity.id,
                          completed: value,
                        );
                  },
                ),
                const SizedBox(height: AppDesignConstants.v2GapInline),
              ],
            if (view.showProLock) ...[
              const SizedBox(height: AppDesignConstants.v2GapControl),
              _ProPersonalizedLockRow(loc: loc),
            ],
            const SizedBox(height: AppDesignConstants.v2GapControl),
            Text(
              loc.dailyProgramBenefitLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TestsMotivationBanner extends StatelessWidget {
  const _TestsMotivationBanner({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return KeyedSubtree(
      key: const Key('daily_program_tests_banner'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(AppRoutes.v2Tests),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.dailyProgramTestsBannerTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: AppDesignConstants.minTouchTarget,
                    child: FilledButton(
                      key: const Key('daily_program_tests_banner_cta'),
                      onPressed: () => context.push(AppRoutes.v2Tests),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.goldDim,
                        foregroundColor: AppColors.goldText,
                      ),
                      child: Text(
                        loc.dailyProgramTestsBannerCta,
                        style: const TextStyle(
                          color: AppColors.goldText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCheckCard extends ConsumerWidget {
  const _ActivityCheckCard({
    required this.loc,
    required this.activity,
    required this.selectedDay,
    required this.onToggle,
  });

  final AppLocalizations loc;
  final StructuredDailyActivity activity;
  final DateTime selectedDay;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppColors.of(context);
    final kind = resolveDailyProgramActivityKind(
      id: activity.id,
      titleKey: activity.titleKey,
    );
    final title = resolveStructuredDailyActivityTitle(loc, activity.titleKey);
    final accent = _accentFor(kind);
    final icon = _iconFor(kind);
    final durationLabel = loc.dailyProgramMinutesOnly(activity.minutes);

    return KeyedSubtree(
      key: Key('structured_daily_activity_${activity.id}'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _onOpen(context, ref, kind),
          onLongPress: () => onToggle(!activity.completed),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: activity.completed
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : palette.card,
                borderRadius: BorderRadius.circular(18),
                border: Border(
                  left: BorderSide(color: accent, width: 4),
                  top: BorderSide(
                    color: activity.completed
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : palette.border,
                  ),
                  right: BorderSide(
                    color: activity.completed
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : palette.border,
                  ),
                  bottom: BorderSide(
                    color: activity.completed
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : palette.border,
                  ),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(icon, color: accent, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.3,
                              decoration: activity.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            durationLabel,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CheckBadge(completed: activity.completed),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onOpen(
    BuildContext context,
    WidgetRef ref,
    DailyProgramActivityKind kind,
  ) async {
    final day = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final dayParam =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    switch (kind) {
      case DailyProgramActivityKind.reading:
      case DailyProgramActivityKind.screenFree:
        final title =
            resolveStructuredDailyActivityTitle(loc, activity.titleKey);
        await context.push(
          AppRoutes.v2DailyProgramTimerWith(
            activityId: activity.id,
            minutes: activity.minutes,
            title: title,
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.pomodoro:
        final anchor = homePomodoroAnchorKey.currentContext;
        if (anchor != null) {
          await Scrollable.ensureVisible(
            anchor,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.15,
          );
        } else {
          await context.push(AppRoutes.pomodoro);
        }
      case DailyProgramActivityKind.cognitiveNBack:
        await context.push(
          AppRoutes.v2DailyProgramCognitiveWith(
            activityId: activity.id,
            kind: 'nback',
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.cognitiveStroop:
        await context.push(
          AppRoutes.v2DailyProgramCognitiveWith(
            activityId: activity.id,
            kind: 'stroop',
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.cognitiveDigitSpan:
        await context.push(AppRoutes.cognitiveMemory);
      case DailyProgramActivityKind.iqChallenge:
        await context.push(AppRoutes.v2IqTest);
        if (context.mounted) {
          await ref.read(structuredDailyProgramControllerProvider).toggle(
                day: day,
                activityId: activity.id,
                completed: true,
              );
        }
      case DailyProgramActivityKind.eveningReview:
        await context.push(
          AppRoutes.v2EveningReviewWith(
            activityId: activity.id,
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.rule:
      case DailyProgramActivityKind.other:
        onToggle(!activity.completed);
    }
  }

  Color _accentFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => AppColors.gold,
      DailyProgramActivityKind.pomodoro => AppColors.primary,
      DailyProgramActivityKind.screenFree => AppColors.info,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        AppColors.accentPurple,
      DailyProgramActivityKind.iqChallenge => AppColors.accentPurple,
      DailyProgramActivityKind.eveningReview => AppColors.accentOrange,
      DailyProgramActivityKind.rule ||
      DailyProgramActivityKind.other =>
        AppColors.textSecondary,
    };
  }

  IconData _iconFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => Icons.menu_book,
      DailyProgramActivityKind.pomodoro => Icons.timer,
      DailyProgramActivityKind.screenFree => Icons.phone_android,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        Icons.psychology,
      DailyProgramActivityKind.iqChallenge => Icons.psychology,
      DailyProgramActivityKind.eveningReview => Icons.edit_note,
      DailyProgramActivityKind.rule => Icons.rule,
      DailyProgramActivityKind.other => Icons.check_circle_outline,
    };
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: completed
            ? AppColors.primary.withValues(alpha: 0.2)
            : palette.cardSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed ? AppColors.primary : palette.border,
        ),
      ),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: completed
              ? const Icon(Icons.check, color: AppColors.primary, size: 18)
              : null,
        ),
      ),
    );
  }
}

class _ProPersonalizedLockRow extends StatelessWidget {
  const _ProPersonalizedLockRow({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return KeyedSubtree(
      key: const Key('structured_daily_program_pro_lock'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(
            AppRoutes.v2PremiumWithSource('pro_gate'),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.dailyProgramPersonalizedLocked,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.homeUpgradeToPro,
                          style: const TextStyle(
                            color: AppColors.goldText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: palette.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
