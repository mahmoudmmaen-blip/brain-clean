import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dashboard/application/seven_day_provider.dart';
import '../../dashboard/domain/daily_snapshot.dart';
import '../data/anxiety_repository_provider.dart';

part 'calm_index_provider.g.dart';

class CalmIndexChartData {
  const CalmIndexChartData({
    required this.spots,
    required this.showLine,
  });

  final List<FlSpot> spots;
  final bool showLine;

  static const empty = CalmIndexChartData(spots: [], showLine: false);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isPaddedSnapshot(DailySnapshot snapshot) => snapshot.date.year == 2000;

@riverpod
Future<CalmIndexChartData> calmIndexChartData(CalmIndexChartDataRef ref) async {
  final snapshots = await ref.watch(sevenDaySnapshotsProvider.future);
  final results = await ref.watch(anxietyRepositoryProvider).getAllResults();

  if (results.length < 2) return CalmIndexChartData.empty;

  final anxietyByDay = <DateTime, List<double>>{};
  for (final result in results) {
    final day = _dateOnly(result.timestamp.toLocal());
    anxietyByDay.putIfAbsent(day, () => []).add(result.score);
  }

  final dailyAnxiety = anxietyByDay.map(
    (day, scores) => MapEntry(
      day,
      scores.reduce((a, b) => a + b) / scores.length,
    ),
  );

  double? interpolateCalmIndex(int index) {
    DateTime? beforeDay;
    double? beforeCalm;
    DateTime? afterDay;
    double? afterCalm;

    for (var i = 0; i < snapshots.length; i++) {
      if (_isPaddedSnapshot(snapshots[i])) continue;
      final day = _dateOnly(snapshots[i].date);
      final anxiety = dailyAnxiety[day];
      if (anxiety == null) continue;
      final calm = 100 - anxiety;
      if (i < index) {
        beforeDay = day;
        beforeCalm = calm;
      } else if (i > index && afterCalm == null) {
        afterDay = day;
        afterCalm = calm;
      }
    }

    final day = _isPaddedSnapshot(snapshots[index])
        ? null
        : _dateOnly(snapshots[index].date);
    if (day != null) {
      final direct = dailyAnxiety[day];
      if (direct != null) return 100 - direct;
    }

    if (beforeCalm != null && afterCalm != null && beforeDay != null && afterDay != null) {
      final total = afterDay.difference(beforeDay).inDays;
      if (total == 0) return beforeCalm;
      final targetDay = _isPaddedSnapshot(snapshots[index])
          ? beforeDay
          : _dateOnly(snapshots[index].date);
      final elapsed = targetDay.difference(beforeDay).inDays;
      final t = elapsed / total;
      return beforeCalm + (afterCalm - beforeCalm) * t;
    }
    return beforeCalm ?? afterCalm;
  }

  final spots = <FlSpot>[];
  for (var i = 0; i < snapshots.length; i++) {
    final calm = interpolateCalmIndex(i);
    if (calm != null) {
      spots.add(FlSpot(i.toDouble(), calm.clamp(0, 100)));
    }
  }

  return CalmIndexChartData(
    spots: spots,
    showLine: results.length >= 2 && spots.length >= 2,
  );
}
