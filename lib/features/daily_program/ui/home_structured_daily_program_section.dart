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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return async.when(
      loading: () => V2InfoCard(
        child: Text(
          loc.v2TodayHomeLoading,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
        ),
      ),
      error: (_, __) => V2InfoCard(
        child: Text(
          loc.homeDailyProgramEmptyBody,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onSurface,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
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
                      Icon(Icons.star_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.dailyProgramTestsBannerTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w800,
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
                      child: Text(loc.dailyProgramTestsBannerCta),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final kind = resolveDailyProgramActivityKind(
      id: activity.id,
      titleKey: activity.titleKey,
    );
    final title = resolveStructuredDailyActivityTitle(loc, activity.titleKey);
    final accent = _accentFor(kind);
    final icon = _iconFor(kind);
    final emoji = _emojiFor(kind);
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
                  // Use start-side accent via directional border.
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
                    // Emoji with system emoji fallback (avoids blank Tajawal glyphs).
                    Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontFamilyFallback: [
                          'Segoe UI Emoji',
                          'Apple Color Emoji',
                          'Noto Color Emoji',
                          'EmojiOne Color',
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: accent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: onSurface,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                      decoration: activity.completed
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationColor: palette.textSecondary,
                                    ) ??
                                TextStyle(
                                  color: onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            durationLabel,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: palette.textSecondary,
                                      fontWeight: FontWeight.w600,
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
      DailyProgramActivityKind.iqChallenge => AppColors.accentOrange,
      DailyProgramActivityKind.eveningReview => AppColors.accentOrange,
      DailyProgramActivityKind.rule ||
      DailyProgramActivityKind.other =>
        AppColors.textSecondary,
    };
  }

  IconData _iconFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => Icons.menu_book_outlined,
      DailyProgramActivityKind.pomodoro => Icons.timer_outlined,
      DailyProgramActivityKind.screenFree => Icons.phonelink_erase_outlined,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        Icons.psychology_alt_outlined,
      DailyProgramActivityKind.iqChallenge => Icons.grid_view_outlined,
      DailyProgramActivityKind.eveningReview => Icons.edit_note_outlined,
      DailyProgramActivityKind.rule => Icons.rule_outlined,
      DailyProgramActivityKind.other => Icons.check_circle_outline,
    };
  }

  String _emojiFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => '📚',
      DailyProgramActivityKind.pomodoro => '🎯',
      DailyProgramActivityKind.screenFree => '📵',
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        '🧠',
      DailyProgramActivityKind.iqChallenge => '🧩',
      DailyProgramActivityKind.eveningReview => '✍️',
      DailyProgramActivityKind.rule => '📌',
      DailyProgramActivityKind.other => '✅',
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
          child: Text(
            completed ? '✓' : '',
            style: TextStyle(
              color: completed ? AppColors.primary : palette.textTertiary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
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
              // Gold border only — keep surface on theme card (dark in dark modes).
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.dailyProgramPersonalizedLocked,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.homeUpgradeToPro,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.goldText,
                                    fontWeight: FontWeight.w600,
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
