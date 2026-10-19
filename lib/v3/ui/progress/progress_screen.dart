import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';
import '../../data/clarity_result.dart';
import '../../data/day_progress.dart';
import '../../data/evening_check_in.dart';
import '../../domain/program_engine.dart';
import '../../domain/progress_calendar.dart';
import '../../domain/progress_stats.dart';
import '../../domain/usage_math.dart';
import '../../routing/v3_routes.dart';
import '../shell/v3_tab_placeholder.dart';
import 'usage_access_sheet.dart';
import 'usage_summary_card.dart';

class V3ProgressScreen extends ConsumerStatefulWidget {
  const V3ProgressScreen({super.key, this.nowOverride});

  final DateTime? nowOverride;

  @override
  ConsumerState<V3ProgressScreen> createState() => _V3ProgressScreenState();
}

class _V3ProgressScreenState extends ConsumerState<V3ProgressScreen> {
  bool _askedThisVisit = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final isArabic = locale.toLowerCase().startsWith('ar');
    final appAsync = ref.watch(v3AppStateProvider);
    final now = widget.nowOverride ?? DateTime.now();
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      key: V3ShellKeys.progressTab,
      backgroundColor: AppDesignConstants.darkBackground,
      body: appAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (app) {
          final day1Done = app.dayProgress.any(
            (p) => p.day == 1 && ProgramEngine.isDayCompleted(p),
          );
          if (!day1Done) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.all(AppDesignConstants.paddingScreen),
                child: Center(
                  child: Card(
                    key: const Key('v3_progress_empty'),
                    color: AppDesignConstants.darkSurface,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDesignConstants.paddingCard),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.v3ProgressEmptyTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height:
                                  AppDesignConstants.arabicBodyLineHeight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            key: const Key('v3_progress_empty_cta'),
                            onPressed: () => context.go(V3Routes.today),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppDesignConstants.brandGreen,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(loc.v3ProgressEmptyCta),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final stats = ProgressStats.fromState(
            dayProgress: app.dayProgress,
            clarityResults: app.clarityResults,
            focusLogs: app.focusLogs,
            sosLogs: app.sosLogs,
            now: now,
          );

          if (!_askedThisVisit) {
            _askedThisVisit = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              maybeShowUsageAccessSheet(
                context,
                ref,
                trigger: UsageAskTrigger.progressOpen,
              );
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.v3TabProgress,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ClaritySection(
                    results: app.clarityResults,
                    stats: stats,
                    loc: loc,
                    rtl: rtl,
                  ),
                  const SizedBox(height: 24),
                  if (stats.hasPhoneHours) ...[
                    _PhoneHoursCard(stats: stats, loc: loc),
                    const SizedBox(height: 16),
                  ],
                  UsageSummaryCard(nowOverride: widget.nowOverride),
                  const SizedBox(height: 24),
                  _CalendarSection(
                    progress: app.dayProgress,
                    now: now,
                    isArabic: isArabic,
                    loc: loc,
                  ),
                  const SizedBox(height: 24),
                  _StatsGrid(stats: stats, loc: loc),
                  const SizedBox(height: 24),
                  _MoodChart(
                    checkIns: app.eveningCheckIns,
                    now: now,
                    loc: loc,
                    rtl: rtl,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClaritySection extends StatelessWidget {
  const _ClaritySection({
    required this.results,
    required this.stats,
    required this.loc,
    required this.rtl,
  });

  final List<ClarityResult> results;
  final ProgressStats stats;
  final AppLocalizations loc;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final raw = [
      for (final r in results)
        FlSpot(r.programDay.toDouble(), r.score.toDouble()),
    ];
    // Negative x in RTL so day 1 sits on the right without mirroring labels.
    final spots = rtl
        ? [for (final s in raw) FlSpot(-s.x, s.y)]
        : raw;

    double minX = 1;
    double maxX = 30;
    if (spots.isNotEmpty) {
      minX = spots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
      maxX = spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
      if ((maxX - minX).abs() < 0.01) {
        minX -= 1;
        maxX += 1;
      }
    }

    final chart = spots.isEmpty
        ? const SizedBox(height: 180)
        : SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: 100,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (!spots.any((s) => (s.x - value).abs() < 0.01)) {
                          return const SizedBox.shrink();
                        }
                        final day = value.abs().toInt();
                        return Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppDesignConstants.darkOnSurfaceDim,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppDesignConstants.brandGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
              duration: Duration.zero,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.v3ClarityScoreLabel,
          style: const TextStyle(
            fontSize: AppDesignConstants.typeH3,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (stats.clarityLatest != null) ...[
          const SizedBox(height: 8),
          Text(
            key: const Key('v3_progress_clarity_latest'),
            '${stats.clarityLatest}',
            style: const TextStyle(
              fontSize: AppDesignConstants.v2MetricValueSize,
              fontWeight: FontWeight.bold,
              height: AppDesignConstants.v2MetricValueHeight,
              color: AppDesignConstants.brandGreen,
            ),
          ),
          if (stats.hasClarityTrend)
            Text(
              key: const Key('v3_progress_clarity_from_to'),
              loc.v3ProgressClarityFromTo(
                stats.clarityFirst!,
                stats.clarityLatest!,
              ),
              style: const TextStyle(
                color: AppDesignConstants.darkOnSurfaceMuted,
              ),
            ),
        ],
        const SizedBox(height: 12),
        KeyedSubtree(
          key: Key('v3_progress_clarity_chart_${raw.length}'),
          child: chart,
        ),
      ],
    );
  }
}

class _PhoneHoursCard extends StatelessWidget {
  const _PhoneHoursCard({required this.stats, required this.loc});

  final ProgressStats stats;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final from = stats.phoneHoursFirst!;
    final to = stats.phoneHoursLatest!;
    return Card(
      key: const Key('v3_progress_phone_hours'),
      color: AppDesignConstants.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.v3ProgressPhoneHoursTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              loc.v3ProgressPhoneHoursFromTo(
                _fmtHours(from),
                _fmtHours(to),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtHours(double h) {
    if (h == h.roundToDouble()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.progress,
    required this.now,
    required this.isArabic,
    required this.loc,
  });

  final List<DayProgress> progress;
  final DateTime now;
  final bool isArabic;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final headers = ProgressCalendar.weekdayHeaders(arabicLocale: isArabic);
    final labels = [
      for (final wd in headers) _weekdayLabel(loc, wd, isArabic),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.v3ProgressCalendarTitle,
          style: const TextStyle(
            fontSize: AppDesignConstants.typeH3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          key: Key(isArabic
              ? 'v3_progress_calendar_weekstart_sat'
              : 'v3_progress_calendar_weekstart_mon'),
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesignConstants.darkOnSurfaceDim,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          key: const Key('v3_progress_calendar_grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final day = index + 1;
            final cell = ProgressCalendar.cellState(
              day: day,
              progress: progress,
              now: now,
            );
            return _CalendarCell(day: day, cell: cell);
          },
        ),
      ],
    );
  }

  static String _weekdayLabel(AppLocalizations loc, int weekday, bool ar) {
    // Short labels — Western digits not needed; letters only.
    if (ar) {
      return switch (weekday) {
        DateTime.saturday => 'س',
        DateTime.sunday => 'ح',
        DateTime.monday => 'ن',
        DateTime.tuesday => 'ث',
        DateTime.wednesday => 'ر',
        DateTime.thursday => 'خ',
        DateTime.friday => 'ج',
        _ => '',
      };
    }
    return switch (weekday) {
      DateTime.monday => 'M',
      DateTime.tuesday => 'T',
      DateTime.wednesday => 'W',
      DateTime.thursday => 'T',
      DateTime.friday => 'F',
      DateTime.saturday => 'S',
      DateTime.sunday => 'S',
      _ => '',
    };
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.day, required this.cell});

  final int day;
  final ProgressCalendarCell cell;

  @override
  Widget build(BuildContext context) {
    final color = switch (cell) {
      ProgressCalendarCell.done => AppDesignConstants.brandGreen,
      ProgressCalendarCell.partial => AppDesignConstants.brandGreen.withValues(
          alpha: 0.45,
        ),
      ProgressCalendarCell.missed => AppDesignConstants.accentError.withValues(
          alpha: 0.55,
        ),
      ProgressCalendarCell.today => AppDesignConstants.accentGold,
      ProgressCalendarCell.future => AppDesignConstants.darkBorder,
    };

    return Container(
      key: Key('v3_progress_cal_${day}_${cell.name}'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cell == ProgressCalendarCell.future
            ? AppDesignConstants.darkSurfaceSecondary
            : color.withValues(alpha: cell == ProgressCalendarCell.today ? 0.25 : 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: cell == ProgressCalendarCell.today ? 2 : 1,
        ),
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              cell == ProgressCalendarCell.today ? FontWeight.bold : FontWeight.w500,
          color: cell == ProgressCalendarCell.future
              ? AppDesignConstants.darkOnSurfaceDim
              : AppDesignConstants.darkOnSurface,
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.loc});

  final ProgressStats stats;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    Widget tile(Key key, String label, String value) {
      return Card(
        key: key,
        color: AppDesignConstants.darkSurface,
        child: ListTile(
          title: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppDesignConstants.brandGreen,
            ),
          ),
          subtitle: Text(label),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.v3ProgressStatsTitle,
          style: const TextStyle(
            fontSize: AppDesignConstants.typeH3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        tile(
          const Key('v3_progress_stat_days'),
          loc.v3ProgressStatDays,
          '${stats.daysPracticed}',
        ),
        tile(
          const Key('v3_progress_stat_streak'),
          loc.v3ProgressStatStreak,
          '${stats.currentStreak}',
        ),
        tile(
          const Key('v3_progress_stat_best'),
          loc.v3ProgressStatBestStreak,
          '${stats.bestStreak}',
        ),
        tile(
          const Key('v3_progress_stat_challenges'),
          loc.v3ProgressStatChallenges,
          '${stats.challengesDone}',
        ),
        tile(
          const Key('v3_progress_stat_focus'),
          loc.v3ProgressStatFocus,
          '${stats.focusMinutes}',
        ),
        tile(
          const Key('v3_progress_stat_urges'),
          loc.v3ProgressStatUrges,
          '${stats.urgesBeaten}',
        ),
      ],
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart({
    required this.checkIns,
    required this.now,
    required this.loc,
    required this.rtl,
  });

  final List<EveningCheckIn> checkIns;
  final DateTime now;
  final AppLocalizations loc;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 13));
    final byDate = {for (final c in checkIns) c.date: c.mood};
    final spots = <FlSpot>[];
    for (var i = 0; i < 14; i++) {
      final d = start.add(Duration(days: i));
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final mood = byDate[key];
      if (mood != null) {
        spots.add(FlSpot(i.toDouble(), mood.toDouble()));
      }
    }

    final chartSpots = rtl
        ? [for (final s in spots) FlSpot(-s.x, s.y)]
        : spots;
    final minX = rtl ? -13.0 : 0.0;
    final maxX = rtl ? 0.0 : 13.0;

    final chart = chartSpots.isEmpty
        ? SizedBox(
            height: 100,
            child: Center(
              child: Text(
                loc.v3ProgressMoodEmpty,
                style: const TextStyle(
                  color: AppDesignConstants.darkOnSurfaceDim,
                ),
              ),
            ),
          )
        : SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 1,
                maxY: 5,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartSpots,
                    isCurved: true,
                    color: AppDesignConstants.accentGold,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
              duration: Duration.zero,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.v3ProgressMoodTitle,
          style: const TextStyle(
            fontSize: AppDesignConstants.typeH3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        KeyedSubtree(
          key: const Key('v3_progress_mood_chart'),
          child: chart,
        ),
      ],
    );
  }
}
