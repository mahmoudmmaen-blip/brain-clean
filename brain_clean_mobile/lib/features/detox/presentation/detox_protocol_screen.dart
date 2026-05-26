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
        child: async.when(
          data: (_) => _DetoxProtocolBody(
            liveBcScore: live.bcScore,
            detoxHabitScore: data.detoxHabitScore,
            boredomBefriended: data.boredomBefriended,
            delayedGratificationCount: data.delayedGratificationCount,
            bodyActivated: data.bodyActivated,
            isSyncing: async.isLoading,
            hasSyncError: async.hasError,
            onRetry: controller.loadFromRemote,
            onBoredomChanged: controller.setBoredomBefriended,
            onIncrementDelayed: controller.recordDelayedGratificationWin,
            onDecrementDelayed: () => controller.processDailyCheckIn(
              DailyCheckInInput(
                delayedGratificationCount: data.delayedGratificationCount - 1,
              ),
            ),
            onBodyActivatedChanged: controller.setBodyActivated,
            onReset: controller.resetDailyCheckIns,
          ),
          error: (e, st) => _DetoxProtocolError(
            message: loc.detoxSyncError,
            onRetry: controller.loadFromRemote,
          ),
          loading: () => const _DetoxProtocolLoading(),
        ),
      ),
    );
  }
}

class _DetoxProtocolBody extends StatelessWidget {
  const _DetoxProtocolBody({
    required this.liveBcScore,
    required this.detoxHabitScore,
    required this.boredomBefriended,
    required this.delayedGratificationCount,
    required this.bodyActivated,
    required this.isSyncing,
    required this.hasSyncError,
    required this.onRetry,
    required this.onBoredomChanged,
    required this.onIncrementDelayed,
    required this.onDecrementDelayed,
    required this.onBodyActivatedChanged,
    required this.onReset,
  });

  final double liveBcScore;
  final double detoxHabitScore;
  final bool boredomBefriended;
  final int delayedGratificationCount;
  final bool bodyActivated;
  final bool isSyncing;
  final bool hasSyncError;

  final VoidCallback onRetry;
  final ValueChanged<bool> onBoredomChanged;
  final VoidCallback onIncrementDelayed;
  final VoidCallback onDecrementDelayed;
  final ValueChanged<bool> onBodyActivatedChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetoxLiveScoreCard(
          liveBcScore: liveBcScore,
          detoxHabitScore: detoxHabitScore,
        ),
        const SizedBox(height: 12),
        if (isSyncing)
          const Center(child: CircularProgressIndicator())
        else if (hasSyncError)
          _DetoxInlineErrorCard(message: loc.detoxSyncError, onRetry: onRetry),
        const SizedBox(height: 12),
        _HabitSwitchCard(
          title: loc.detoxBoredomTitle,
          subtitle: loc.detoxBoredomSubtitle,
          value: boredomBefriended,
          onChanged: onBoredomChanged,
        ),
        const SizedBox(height: 12),
        _HabitCounterCard(
          title: loc.detoxDelayedTitle,
          subtitle: loc.detoxDelayedSubtitle(
            BcScoreConstants.maxDelayedGratificationCount,
          ),
          count: delayedGratificationCount,
          onIncrement: onIncrementDelayed,
          onDecrement: onDecrementDelayed,
        ),
        const SizedBox(height: 12),
        _HabitSwitchCard(
          title: loc.detoxBodyTitle,
          subtitle: loc.detoxBodySubtitle,
          value: bodyActivated,
          onChanged: onBodyActivatedChanged,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isSyncing ? null : onReset,
          child: Text(loc.detoxReset),
        ),
      ],
    );
  }
}

class _DetoxProtocolLoading extends StatelessWidget {
  const _DetoxProtocolLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _DetoxProtocolError extends StatelessWidget {
  const _DetoxProtocolError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(loc.detoxRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetoxInlineErrorCard extends StatelessWidget {
  const _DetoxInlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        title: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.orangeAccent),
        ),
        trailing: TextButton(
          onPressed: onRetry,
          child: Text(loc.detoxRetry),
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: liveBcScore),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
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

class _HabitSwitchCard extends StatelessWidget {
  const _HabitSwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
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
  });

  final String title;
  final String subtitle;
  final int count;
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
              onPressed: atMin ? null : onDecrement,
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
              onPressed: atMax ? null : onIncrement,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
