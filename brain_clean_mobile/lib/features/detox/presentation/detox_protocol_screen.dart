import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/bc_score_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../domain/daily_check_in_input.dart';
import 'detox_protocol_controller.dart';

class DetoxProtocolScreen extends ConsumerWidget {
  const DetoxProtocolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode.toLowerCase() == 'ar';

    final async = ref.watch(detoxProtocolControllerProvider);
    final data = ref.watch(detoxProtocolDataProvider);
    final controller = ref.read(detoxProtocolControllerProvider.notifier);

    final live = ref.watch(bcScoreLiveProvider);

    final syncBanner = async.isLoading
        ? loc.detoxSyncing
        : async.hasError
            ? loc.detoxSyncError
            : null;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.detoxTitle),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        loc.detoxLiveBcScoreTitle,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.detoxLiveBcScoreSubtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white54),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${live.bcScoreRounded}%',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.detoxSubtitle} · ${data.detoxHabitScore.round()}/100',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
              if (syncBanner != null) ...[
                const SizedBox(height: 12),
                Text(
                  syncBanner,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: data.boredomBefriended,
                      onChanged: (v) => controller.setBoredomBefriended(v),
                      title: Text(loc.detoxBoredomTitle),
                      subtitle: Text(loc.detoxBoredomSubtitle),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(loc.detoxDelayedTitle),
                      subtitle: Text(
                        loc.detoxDelayedSubtitle(
                          BcScoreConstants.maxDelayedGratificationCount,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: loc.detoxDecrement,
                            onPressed: data.delayedGratificationCount <= 0
                                ? null
                                : () => controller.processDailyCheckIn(
                                      DailyCheckInInput(
                                        delayedGratificationCount:
                                            data.delayedGratificationCount - 1,
                                      ),
                                    ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            loc.detoxCount(data.delayedGratificationCount),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            tooltip: loc.detoxIncrement,
                            onPressed: data.delayedGratificationCount >=
                                    BcScoreConstants.maxDelayedGratificationCount
                                ? null
                                : () => controller.recordDelayedGratificationWin(),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: data.bodyActivated,
                      onChanged: (v) => controller.setBodyActivated(v),
                      title: Text(loc.detoxBodyTitle),
                      subtitle: Text(loc.detoxBodySubtitle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => controller.resetDailyCheckIns(),
                child: Text(loc.detoxReset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

