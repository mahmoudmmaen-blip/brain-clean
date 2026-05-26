import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_colors.dart';
import '../domain/daily_check_in_input.dart';
import 'detox_protocol_controller.dart';

/// 7-day dopamine detox daily check-in — updates [bcScoreLiveProvider] on every input.
class DetoxProtocolScreen extends ConsumerWidget {
  const DetoxProtocolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final async = ref.watch(detoxProtocolControllerProvider);
    final data = ref.watch(detoxProtocolDataProvider);
    final controller = ref.read(detoxProtocolControllerProvider.notifier);
    final live = ref.watch(bcScoreLiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.detoxTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DetoxLiveScoreCard(
              liveBcScore: live.bcScore,
              detoxHabitScore: data.detoxHabitScore,
            ),
            if (async.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (async.hasError) ...[
              const SizedBox(height: 12),
              Text(
                loc.detoxSyncError,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.orangeAccent),
              ),
            ] else if (async.isLoading && async.hasValue) ...[
              const SizedBox(height: 8),
              Text(
                loc.detoxSyncing,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white54),
              ),
            ],
            const SizedBox(height: 20),
            _DetoxHabitCheckInCard(
              boredomBefriended: data.boredomBefriended,
              delayedGratificationCount: data.delayedGratificationCount,
              bodyActivated: data.bodyActivated,
              onBoredomChanged: controller.setBoredomBefriended,
              onBodyActivatedChanged: controller.setBodyActivated,
              onIncrementDelayed: controller.recordDelayedGratificationWin,
              onDecrementDelayed: () => controller.processDailyCheckIn(
                DailyCheckInInput(
                  delayedGratificationCount: data.delayedGratificationCount - 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: async.isLoading ? null : controller.resetDailyCheckIns,
              child: Text(loc.detoxReset),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live BC_score hero — driven by [bcScoreLiveProvider].
class _DetoxLiveScoreCard extends StatelessWidget {
  const _DetoxLiveScoreCard({
    required this.liveBcScore,
    required this.detoxHabitScore,
  });

  final double liveBcScore;
  final double detoxHabitScore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scoreColor = BcScoreColors.forScore(liveBcScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.detoxLiveBcScoreTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.6,
                    color: Colors.white54,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.detoxLiveBcScoreSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              '${liveBcScore.round()}%',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                    height: 1,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '${loc.detoxSubtitle} · ${detoxHabitScore.round()}/100',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three habit pillars: boredom, delayed gratification, body activation.
class _DetoxHabitCheckInCard extends StatelessWidget {
  const _DetoxHabitCheckInCard({
    required this.boredomBefriended,
    required this.delayedGratificationCount,
    required this.bodyActivated,
    required this.onBoredomChanged,
    required this.onBodyActivatedChanged,
    required this.onIncrementDelayed,
    required this.onDecrementDelayed,
  });

  final bool boredomBefriended;
  final int delayedGratificationCount;
  final bool bodyActivated;
  final ValueChanged<bool> onBoredomChanged;
  final ValueChanged<bool> onBodyActivatedChanged;
  final VoidCallback onIncrementDelayed;
  final VoidCallback onDecrementDelayed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const maxDelayed = BcScoreConstants.maxDelayedGratificationCount;
    final atMin = delayedGratificationCount <= 0;
    final atMax = delayedGratificationCount >= maxDelayed;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            value: boredomBefriended,
            onChanged: onBoredomChanged,
            title: Text(loc.detoxBoredomTitle),
            subtitle: Text(loc.detoxBoredomSubtitle),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(loc.detoxDelayedTitle),
            subtitle: Text(loc.detoxDelayedSubtitle(maxDelayed)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: loc.detoxDecrement,
                  onPressed: atMin ? null : onDecrementDelayed,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  loc.detoxCount(delayedGratificationCount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  tooltip: loc.detoxIncrement,
                  onPressed: atMax ? null : onIncrementDelayed,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: bodyActivated,
            onChanged: onBodyActivatedChanged,
            title: Text(loc.detoxBodyTitle),
            subtitle: Text(loc.detoxBodySubtitle),
          ),
        ],
      ),
    );
  }
}
