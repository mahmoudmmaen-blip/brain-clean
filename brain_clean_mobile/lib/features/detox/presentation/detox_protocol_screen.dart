import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/domain/diagnostic_model.dart';
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
    final controller = ref.read(detoxProtocolControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(loc.detoxTitle)),
      body: SafeArea(
        child: async.when(
          data: (_) => _buildContent(context, ref),
          loading: () => _buildLoadingState(context),
          error: (_, __) => _buildErrorState(
            context,
            onRetry: controller.loadFromRemote,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              loc.detoxSyncing,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required Future<void> Function() onRetry,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.detoxSyncError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => onRetry(),
                  child: Text(loc.detoxRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final async = ref.watch(detoxProtocolControllerProvider);
    final data = ref.watch(detoxProtocolDataProvider);
    final live = ref.watch(bcScoreLiveProvider);
    final controller = ref.read(detoxProtocolControllerProvider.notifier);
    final isSyncing = async.isLoading;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetoxLiveScoreCard(
          live: live,
          detoxHabitScore: data.detoxHabitScore,
        ),
        const SizedBox(height: 12),
        if (isSyncing)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  loc.detoxSyncing,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          )
        else if (async.hasError)
          _DetoxInlineErrorCard(
            message: loc.detoxSyncError,
            onRetry: controller.loadFromRemote,
          ),
        const SizedBox(height: 12),
        _HabitSwitchCard(
          title: loc.detoxBoredomTitle,
          subtitle: loc.detoxBoredomSubtitle,
          value: data.boredomBefriended,
          enabled: !isSyncing,
          onChanged: controller.setBoredomBefriended,
        ),
        const SizedBox(height: 12),
        _HabitCounterCard(
          title: loc.detoxDelayedTitle,
          subtitle: loc.detoxDelayedSubtitle(
            BcScoreConstants.maxDelayedGratificationCount,
          ),
          count: data.delayedGratificationCount,
          enabled: !isSyncing,
          onIncrement: controller.recordDelayedGratificationWin,
          onDecrement: () => controller.processDailyCheckIn(
            DailyCheckInInput(
              delayedGratificationCount: data.delayedGratificationCount - 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _HabitSwitchCard(
          title: loc.detoxBodyTitle,
          subtitle: loc.detoxBodySubtitle,
          value: data.bodyActivated,
          enabled: !isSyncing,
          onChanged: controller.setBodyActivated,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isSyncing ? null : controller.resetDailyCheckIns,
          child: Text(loc.detoxReset),
        ),
      ],
    );
  }
}

/// Live BC_score hero — driven by [bcScoreLiveProvider].
class _DetoxLiveScoreCard extends StatelessWidget {
  const _DetoxLiveScoreCard({
    required this.live,
    required this.detoxHabitScore,
  });

  final DiagnosticModel live;
  final double detoxHabitScore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final liveBcScore = live.bcScore;
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
            TweenAnimationBuilder<double>(
              key: ValueKey<int>(liveBcScore.round()),
              tween: Tween<double>(end: liveBcScore),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  '${value.round()}%',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        height: 1,
                      ),
                );
              },
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

class _DetoxInlineErrorCard extends StatelessWidget {
  const _DetoxInlineErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.85),
        ),
        title: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: TextButton(
          onPressed: () => onRetry(),
          child: Text(loc.detoxRetry),
        ),
      ),
    );
  }
}

class _HabitSwitchCard extends StatelessWidget {
  const _HabitSwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _HabitCounterCard extends StatelessWidget {
  const _HabitCounterCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final int count;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const maxDelayed = BcScoreConstants.maxDelayedGratificationCount;
    final atMin = count <= 0;
    final atMax = count >= maxDelayed;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: loc.detoxDecrement,
              onPressed: enabled && !atMin ? onDecrement : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              loc.detoxCount(count),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            IconButton(
              tooltip: loc.detoxIncrement,
              onPressed: enabled && !atMax ? onIncrement : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
