import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/usage_providers.dart';

/// Real usage summary when PACKAGE_USAGE_STATS is granted.
class UsageSummaryCard extends ConsumerStatefulWidget {
  const UsageSummaryCard({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  ConsumerState<UsageSummaryCard> createState() => _UsageSummaryCardState();
}

class _UsageSummaryCardState extends ConsumerState<UsageSummaryCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(usageSnapshotProvider.notifier).refresh();
    }
  }

  String _fmt(double hours) {
    if (hours == hours.roundToDouble()) return hours.toInt().toString();
    return hours.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final async = ref.watch(usageSnapshotProvider);
    final now = widget.nowOverride ?? DateTime.now();

    return async.when(
      loading: () => const SizedBox.shrink(
        key: Key('v3_progress_usage_summary_slot'),
      ),
      error: (_, __) => const SizedBox.shrink(
        key: Key('v3_progress_usage_summary_slot'),
      ),
      data: (snap) {
        if (!snap.hasAccess) {
          return const SizedBox.shrink(
            key: Key('v3_progress_usage_summary_slot'),
          );
        }
        final yesterday = snap.yesterdayHours(now);
        final avg7 = snap.average7Hours(now);
        final fromTo = snap.firstVsLast7();

        return Card(
          key: const Key('v3_progress_usage_summary'),
          color: AppDesignConstants.darkSurface,
          child: Padding(
            padding: const EdgeInsets.all(AppDesignConstants.paddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.v3UsageSummaryTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.v3UsageApproximate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignConstants.darkOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 12),
                if (yesterday != null)
                  Text(loc.v3UsageYesterday(_fmt(yesterday))),
                if (avg7 != null) ...[
                  const SizedBox(height: 4),
                  Text(loc.v3UsageAvg7(_fmt(avg7))),
                ],
                if (fromTo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loc.v3UsageFromTo(_fmt(fromTo.from), _fmt(fromTo.to)),
                    key: const Key('v3_usage_from_to'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
