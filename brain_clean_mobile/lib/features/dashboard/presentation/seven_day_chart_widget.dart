import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/async_state_views.dart';
import '../../anxiety/presentation/calm_index_provider.dart';
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
        child: AsyncStateViews.loading(context),
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
                Icon(
                  Icons.show_chart,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.chartEmptyState,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _ChartBody extends ConsumerWidget {
  const _ChartBody({
    required this.snapshots,
    required this.xLabels,
    required this.title,
  });

  final List<DailySnapshot> snapshots;
  final List<String> xLabels;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    final calmAsync = ref.watch(calmIndexChartDataProvider);
    final calmColor = colorScheme.tertiary != colorScheme.primary
        ? colorScheme.tertiary
        : colorScheme.secondary;

    final calmData = calmAsync.valueOrNull ?? CalmIndexChartData.empty;

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: [
          for (var i = 0; i < snapshots.length; i++)
            FlSpot(i.toDouble(), snapshots[i].bcsValue),
        ],
        isCurved: true,
        color: colorScheme.primary,
        barWidth: 2.5,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.2),
              colorScheme.primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ];

    if (calmData.showLine) {
      lineBars.add(
        LineChartBarData(
          spots: calmData.spots,
          isCurved: true,
          color: calmColor,
          barWidth: 2.5,
          dashArray: const [4, 4],
          dotData: const FlDotData(show: true),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
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
                    color: dividerColor,
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
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
                            TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: lineBars,
              ),
            ),
          ),
          if (calmData.showLine) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _LegendDot(
                  color: colorScheme.primary,
                  label: loc.calmIndexLegendBci,
                ),
                _LegendDot(
                  color: calmColor,
                  label: loc.calmIndexLegendCalm,
                  dashed: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(20, 4),
          painter: _LegendLinePainter(color: color, dashed: dashed),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LegendLinePainter extends CustomPainter {
  _LegendLinePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (dashed) {
      const dashWidth = 4.0;
      const gap = 3.0;
      var x = 0.0;
      while (x < size.width) {
        final end = (x + dashWidth).clamp(0.0, size.width).toDouble();
        canvas.drawLine(Offset(x, size.height / 2), Offset(end, size.height / 2), paint);
        x += dashWidth + gap;
      }
    } else {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LegendLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}
