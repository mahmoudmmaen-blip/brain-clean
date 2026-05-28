import 'package:flutter/foundation.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(loc.detoxTitle)),
      body: SafeArea(
        child: async.when(
          data: (_) => _buildContent(context, ref),
          loading: () => _buildLoadingView(context),
          error: (error, stack) => _buildErrorView(context, ref, error, stack),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return const _DetoxProtocolLoadingView();
  }

  Widget _buildErrorView(
    BuildContext context,
    WidgetRef ref,
    Object error,
    StackTrace stack,
  ) {
    return _DetoxProtocolErrorView(
      error: error,
      stackTrace: stack,
      onRetry: () => _invalidateAndResyncDetox(ref),
    );
  }

  /// Restarts the detox sync lifecycle via provider invalidation (non-blocking).
  void _invalidateAndResyncDetox(WidgetRef ref) {
    ref.invalidate(detoxProtocolControllerProvider);
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
          const _DetoxSyncingBanner()
        else if (async.hasError)
          _DetoxInlineErrorCard(
            message: loc.detoxSyncError,
            onRetry: () => _invalidateAndResyncDetox(ref),
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

/// Full-screen loading while the detox controller hydrates from remote.
class _DetoxProtocolLoadingView extends StatelessWidget {
  const _DetoxProtocolLoadingView();

  @override
  Widget build(BuildContext context) {
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
}

/// Full-screen fatal sync error with localized [detoxRetry].
class _DetoxProtocolErrorView extends StatelessWidget {
  const _DetoxProtocolErrorView({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('DetoxProtocol sync error: $error\n$stackTrace');
      return true;
    }());
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
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                _DetoxRetryButton(onRetry: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Localized retry — invalidates [detoxProtocolControllerProvider] (non-blocking).
class _DetoxRetryButton extends StatelessWidget {
  const _DetoxRetryButton({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FilledButton(
      onPressed: onRetry,
      child: Text(loc.detoxRetry),
    );
  }
}

/// Inline sync indicator while a habit write is in flight.
class _DetoxSyncingBanner extends StatelessWidget {
  const _DetoxSyncingBanner();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
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
  final VoidCallback onRetry;

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
          onPressed: onRetry,
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
