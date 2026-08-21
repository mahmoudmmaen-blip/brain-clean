import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../application/structured_daily_program_provider.dart';
import '../domain/structured_daily_activity.dart';
import '../domain/structured_daily_activity_l10n.dart';

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
            for (final activity in view.activities) ...[
              _ActivityCheckCard(
                loc: loc,
                activity: activity,
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
          ],
        );
      },
    );
  }
}

class _ActivityCheckCard extends StatelessWidget {
  const _ActivityCheckCard({
    required this.loc,
    required this.activity,
    required this.onToggle,
  });

  final AppLocalizations loc;
  final StructuredDailyActivity activity;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final title = resolveStructuredDailyActivityTitle(loc, activity.titleKey);
    final line = loc.dailyProgramActivityLine(title, activity.minutes);
    final checkMark = activity.completed ? '✓' : ' ';

    return KeyedSubtree(
      key: Key('structured_daily_activity_${activity.id}'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onToggle(!activity.completed),
          child: V2InfoCard(
            child: Semantics(
              checked: activity.completed,
              label: '[$checkMark] $line',
              child: Text(
                '[$checkMark] $line',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: activity.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: palette.textSecondary,
                    ),
              ),
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
          child: V2InfoCard(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.goldText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: palette.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
