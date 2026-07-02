import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../home_streak_provider.dart';

const homeStreakTimerKey = Key('home_streak_timer_grid');

/// 4-column streak timer (D / H / M / S) — updates every second.
class HomeStreakTimerGrid extends ConsumerWidget {
  const HomeStreakTimerGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final streak = ref.watch(homeStreakSnapshotProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Card(
      key: homeStreakTimerKey,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
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
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              width: 1,
              height: 44,
              color: dividerColor,
            ),
        ],
      ),
    );
  }
}
