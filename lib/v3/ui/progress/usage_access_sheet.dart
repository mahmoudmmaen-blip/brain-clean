import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/usage_providers.dart';
import '../../domain/usage_math.dart';

/// Shows the opt-in usage-access sheet at most twice per install.
Future<void> maybeShowUsageAccessSheet(
  BuildContext context,
  WidgetRef ref, {
  required UsageAskTrigger trigger,
}) async {
  final snap = await ref.read(usageSnapshotProvider.notifier).refresh();
  final show = UsageAskGate.shouldShow(
    trigger: trigger,
    askCount: snap.ask.askCount,
    ask1Declined: snap.ask.ask1Declined,
    hasAccess: snap.hasAccess,
  );
  if (!show || !context.mounted) return;

  await ref.read(usageSnapshotProvider.notifier).recordAskShown();
  if (!context.mounted) return;

  final later = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignConstants.darkSurface,
    builder: (ctx) => const _UsageAccessSheetBody(),
  );

  if (later == true) {
    await ref.read(usageSnapshotProvider.notifier).recordAskDeclined();
  } else if (later == false) {
    await ref.read(usageDataSourceProvider).openSettings();
  }
  await ref.read(usageSnapshotProvider.notifier).refresh();
}

class _UsageAccessSheetBody extends StatelessWidget {
  const _UsageAccessSheetBody();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.v3UsageAskBody,
              key: const Key('v3_usage_ask_body'),
              style: const TextStyle(fontSize: 16, height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              loc.v3UsageAskPrivacy,
              style: const TextStyle(
                fontSize: 13,
                color: AppDesignConstants.darkOnSurfaceMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('v3_usage_ask_open_settings'),
              onPressed: () => Navigator.of(context).pop(false),
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(loc.v3UsageAskOpenSettings),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('v3_usage_ask_later'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.v3UsageAskLater),
            ),
          ],
        ),
      ),
    );
  }
}
