import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../data/pillar_metrics_repository_provider.dart';
import '../domain/pillar_metric_snapshot.dart';

/// Pillar charts + day-one comparison + weekly re-diagnosis entry.
class ProgressPillarSection extends ConsumerWidget {
  const ProgressPillarSection({super.key});

  static const _pillars = [
    ('attention', 'diagMetricAttention'),
    ('workingMemory', 'diagMetricWorkingMemory'),
    ('screenHabits', 'diagMetricScreenHabits'),
    ('sleepQuality', 'diagMetricSleepQuality'),
  ];

  String _label(AppLocalizations loc, String key) => switch (key) {
        'diagMetricAttention' => loc.diagMetricAttention,
        'diagMetricWorkingMemory' => loc.diagMetricWorkingMemory,
        'diagMetricScreenHabits' => loc.diagMetricScreenHabits,
        'diagMetricSleepQuality' => loc.diagMetricSleepQuality,
        _ => key,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(pillarProgressComparisonProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (comparison) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V2SectionLabel(loc.v2ProgressPillarsHeading),
            const SizedBox(height: AppDesignConstants.v2GapControl),
            if (!comparison.hasData)
              V2InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.v2ProgressPillarsEmpty,
                      style: V2ShellVisual.bodyMuted(theme),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.push(AppRoutes.v2InteractiveDiagnostic),
                      child: Text(loc.v2ProgressPillarsFirstDiagnostic),
                    ),
                  ],
                ),
              )
            else ...[
              V2InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.v2ProgressLiveVsDayOne,
                      style: V2ShellVisual.sectionLabel(theme),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.v2ProgressOverallDelta(
                        _overallDelta(comparison),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.v2ProgressBaselineDate(
                        _formatDate(comparison.baseline!.recordedAt),
                      ),
                      style: V2ShellVisual.captionMuted(theme),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesignConstants.v2GapControl),
              for (final (id, l10nKey) in _pillars)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDesignConstants.v2GapControl,
                  ),
                  child: _PillarChartCard(
                    title: _label(loc, l10nKey),
                    baseline: comparison.baseline!.valueForKey(id),
                    current: comparison.latest!.valueForKey(id),
                    history: comparison.history
                        .map((s) => s.valueForKey(id).toDouble())
                        .toList(growable: false),
                    baselineLabel: loc.v2ProgressChartDayOne,
                    currentLabel: loc.v2ProgressChartToday,
                  ),
                ),
            ],
            const SizedBox(height: AppDesignConstants.v2GapTight),
            SizedBox(
              height: AppDesignConstants.minTouchTarget,
              child: OutlinedButton(
                style: V2ShellVisual.secondaryOutlined(),
                onPressed: () =>
                    context.push(AppRoutes.v2InteractiveDiagnostic),
                child: Text(loc.v2ProgressWeeklyRediagnosis),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _overallDelta(PillarProgressComparison c) {
    if (!c.hasData) return '0';
    final keys = ['attention', 'workingMemory', 'screenHabits', 'sleepQuality'];
    var sum = 0;
    for (final k in keys) {
      sum += c.deltaFor(k);
    }
    final avg = (sum / keys.length).round();
    if (avg > 0) return '+$avg%';
    return '$avg%';
  }
}

class _PillarChartCard extends StatelessWidget {
  const _PillarChartCard({
    required this.title,
    required this.baseline,
    required this.current,
    required this.history,
    required this.baselineLabel,
    required this.currentLabel,
  });

  final String title;
  final int baseline;
  final int current;
  final List<double> history;
  final String baselineLabel;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = current - baseline;
    final deltaText = delta > 0 ? '+$delta%' : '$delta%';

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                deltaText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: delta >= 0 ? AppColors.primary : AppColors.goldText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = value == 0
                            ? baselineLabel
                            : value == 1
                                ? currentLabel
                                : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: baseline.toDouble(),
                        color: AppColors.textSecondary,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: current.toDouble(),
                        color: AppColors.primary,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (history.length > 2) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < history.length; i++)
                          FlSpot(i.toDouble(), history[i]),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
