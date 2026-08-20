import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/glow_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/v2_shell_visual.dart';

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
    final pct = (progress.clamp(0, 1) * 100).round();

    return DecoratedBox(
      decoration: V2ShellVisual.infoCardDecoration(Theme.of(context)),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.v2InfoPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.recoveryProgressSummary(completedDays, totalDays),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            GlowProgressBar(
              progress: progress.clamp(0, 1),
              height: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '$pct%',
              textAlign: TextAlign.end,
              style: V2ShellVisual.metricValue(theme)?.copyWith(
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
