import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../domain/diag_metric.dart';
import '../domain/diag_scoring.dart';
import 'widgets/diag_result_ring.dart';

class DiagResultView extends StatelessWidget {
  const DiagResultView({
    super.key,
    required this.result,
    required this.planUpdated,
    required this.updatingPlan,
    required this.onContinue,
  });

  final DiagScoreResult result;
  final bool planUpdated;
  final bool updatingPlan;
  final VoidCallback onContinue;

  String _metricLabel(DiagMetric metric, AppLocalizations loc) {
    return switch (metric) {
      DiagMetric.attention => loc.diagMetricAttention,
      DiagMetric.workingMemory => loc.diagMetricWorkingMemory,
      DiagMetric.screenHabits => loc.diagMetricScreenHabits,
      DiagMetric.sleepQuality => loc.diagMetricSleepQuality,
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final weakestLabel = _metricLabel(result.weakestMetric, loc);

    return ListView(
      padding: V2ShellVisual.pagePadding(top: 8),
      children: [
        V2PageHeader(title: loc.diagResultTitle),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        Center(
          child: DiagResultRing(
            percent: result.overallPercent,
            label: loc.diagResultOverallLabel,
          ),
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        Text(
          loc.diagResultBreakdownTitle,
          style: V2ShellVisual.sectionLabel(theme),
        ),
        const SizedBox(height: AppDesignConstants.v2GapControl),
        for (final score in result.metricScores)
          _MetricRow(
            label: _metricLabel(score.metric, loc),
            percent: score.percent,
            highlighted: score.metric == result.weakestMetric,
            weakestHint: loc.diagResultWeakestHint,
          ),
        const SizedBox(height: AppDesignConstants.v2GapControl),
        V2InfoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                planUpdated ? Icons.auto_graph_outlined : Icons.hourglass_top,
                color: planUpdated ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  planUpdated
                      ? loc.diagResultPlanUpdated(weakestLabel)
                      : loc.diagResultPlanUpdating,
                  style: V2ShellVisual.bodyMuted(theme),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton(
            onPressed: updatingPlan ? null : onContinue,
            child: updatingPlan
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(loc.diagResultContinue),
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.percent,
    required this.highlighted,
    required this.weakestHint,
  });

  final String label;
  final int percent;
  final bool highlighted;
  final String weakestHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: highlighted ? AppColors.goldText : AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: AppColors.card,
                color: highlighted ? AppColors.goldText : AppColors.primary,
              ),
            ),
            if (highlighted) ...[
              const SizedBox(height: 8),
              Text(
                weakestHint,
                style: V2ShellVisual.captionMuted(theme)?.copyWith(
                  color: AppColors.goldText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
