import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Overall 30-day protocol completion summary.
class RecoveryProgressCard extends StatelessWidget {
  const RecoveryProgressCard({
    super.key,
    required this.completedDays,
    required this.totalDays,
    required this.progress,
  });

  final int completedDays;
  final int totalDays;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.recoveryProgressSummary(completedDays, totalDays),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 10,
                backgroundColor: context.surfaceMuted,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
