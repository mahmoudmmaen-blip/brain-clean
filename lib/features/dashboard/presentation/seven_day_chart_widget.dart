import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/async_state_views.dart';
import '../../../core/theme/app_colors.dart';
import '../application/seven_day_provider.dart';
import '../domain/daily_snapshot.dart';

const chartEmptyStateKey = Key('chart_empty_state');

/// 7-day BCS line chart for the home dashboard.
class SevenDayChartWidget extends ConsumerWidget {
  const SevenDayChartWidget({super.key});

  static List<String> _dayLabels(AppLocalizations loc) => [
        loc.chartDaySat,
        loc.chartDaySun,
        loc.chartDayMon,
        loc.chartDayTue,
        loc.chartDayWed,
        loc.chartDayThu,
        loc.chartDayFri,
      ];

  static bool _isEmptyChart(List<DailySnapshot> snapshots) =>
      snapshots.every((s) => s.bcsValue == 0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final snapshotsAsync = ref.watch(sevenDaySnapshotsProvider);

    return snapshotsAsync.when(
      loading: () => _CardShell(
        title: loc.chartSevenDayTitle,
        child: AsyncStateViews.loading(),
      ),
      error: (_, __) => _CardShell(
        title: loc.chartSevenDayTitle,
        child: AsyncStateViews.error(context),
      ),
      data: (snapshots) {
        if (_isEmptyChart(snapshots)) {
          return _CardShell(
            title: loc.chartSevenDayTitle,
            child: Column(
              key: chartEmptyStateKey,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.show_chart,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.chartEmptyState,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RepaintBoundary(
          child: _ChartBody(
            snapshots: snapshots,
            xLabels: _dayLabels(loc),
            title: loc.chartSevenDayTitle,
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({
    required this.snapshots,
    required this.xLabels,
    required this.title,
  });

  final List<DailySnapshot> snapshots;
  final List<String> xLabels;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 ||
                            value == 25 ||
                            value == 50 ||
                            value == 75 ||
                            value == 100) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= xLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            xLabels[i],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map(
                          (s) => LineTooltipItem(
                            s.y.toStringAsFixed(0),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < snapshots.length; i++)
                        FlSpot(i.toDouble(), snapshots[i].bcsValue),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
