import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../home_streak_provider.dart';

const homeStreakTimerKey = Key('home_streak_timer_grid');

/// 4-column streak timer (D / H / M / S) — updates every second.
class HomeStreakTimerGrid extends ConsumerWidget {
  const HomeStreakTimerGrid({super.key});

  static const _valueColor = Colors.white;
  static const _labelColor = Color(0xFF8B949E);
  static const _dividerColor = Color(0xFF30363D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final streak = ref.watch(homeStreakSnapshotProvider);

    return Card(
      key: homeStreakTimerKey,
      color: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _dividerColor),
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
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: HomeStreakTimerGrid._valueColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: HomeStreakTimerGrid._labelColor,
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
              color: HomeStreakTimerGrid._dividerColor,
            ),
        ],
      ),
    );
  }
}
