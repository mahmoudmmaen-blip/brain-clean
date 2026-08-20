import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';

class DiagIntroView extends StatelessWidget {
  const DiagIntroView({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final metrics = [
      loc.diagMetricAttention,
      loc.diagMetricWorkingMemory,
      loc.diagMetricScreenHabits,
      loc.diagMetricSleepQuality,
    ];

    return ListView(
      padding: V2ShellVisual.pagePadding(top: 8),
      children: [
        V2PageHeader(
          title: loc.diagIntroTitle,
          subtitle: loc.diagIntroBody,
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        V2InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.diagIntroMetricsTitle,
                style: V2ShellVisual.sectionLabel(theme),
              ),
              const SizedBox(height: 12),
              for (final metric in metrics) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        metric,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (metric != metrics.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          loc.diagIntroDurationHint,
          style: V2ShellVisual.captionMuted(theme),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: onStart,
            child: Text(loc.diagIntroStart),
          ),
        ),
      ],
    );
  }
}
