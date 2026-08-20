import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/v2_shell_visual.dart';
import '../home_streak_provider.dart';

const homeStreakTimerKey = Key('home_streak_timer_grid');

/// Focus Journey timer (D / H / M / S) — updates every second via Riverpod.
class HomeStreakTimerGrid extends ConsumerWidget {
  const HomeStreakTimerGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final streak = ref.watch(homeStreakSnapshotProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.homeFocusJourneyTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: V2ShellVisual.metricEyebrow(theme),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: V2ShellVisual.heroCardDecoration(Theme.of(context)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              key: homeStreakTimerKey,
              children: [
                _StreakColumn(
                  value: '${streak.days}',
                  label: loc.homeStreakDays,
                  showDivider: true,
                ),
                _StreakColumn(
                  value: '${streak.hours}',
                  label: loc.homeStreakHours,
                  showDivider: true,
                ),
                _StreakColumn(
                  value: '${streak.minutes}',
                  label: loc.homeStreakMinutes,
                  showDivider: true,
                ),
                _StreakColumn(
                  value: '${streak.seconds}',
                  label: loc.homeStreakSeconds,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakColumn extends StatelessWidget {
  const _StreakColumn({
    required this.value,
    required this.label,
    required this.showDivider,
  });

  final String value;
  final String label;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: V2ShellVisual.metricValue(theme)?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      height: 1.0,
                      letterSpacing: -0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: V2ShellVisual.metricCaption(theme)?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              width: 1,
              height: 48,
              color: AppColors.border,
            ),
        ],
      ),
    );
  }
}
