import '../../data/clarity_result.dart';
import '../../data/day_progress.dart';
import '../../data/sos_log.dart';
import '../../domain/program_engine.dart';

/// Numbers for the day-7 / locked-day paywall personal header.
///
/// Phone-hours chip is reserved for real usage data (C06) — self-report
/// Clarity hours are not shown here.
class PaywallPersonalStats {
  const PaywallPersonalStats({
    required this.completedDays,
    required this.urgesBeaten,
    this.hoursFrom,
    this.hoursTo,
    this.clarityFrom,
    this.clarityTo,
  });

  final int completedDays;
  final int urgesBeaten;

  /// Real usage hours when granted (C06). Null → hide hours chip.
  final double? hoursFrom;
  final double? hoursTo;

  final int? clarityFrom;
  final int? clarityTo;

  bool get hasClarity =>
      clarityFrom != null && clarityTo != null;

  bool get hasHours =>
      hoursFrom != null && hoursTo != null;

  static PaywallPersonalStats fromLocalData({
    required List<DayProgress> dayProgress,
    required List<SosLog> sosLogs,
    required List<ClarityResult> clarityResults,
    double? usageHoursFrom,
    double? usageHoursTo,
  }) {
    final completed = ProgramEngine.completedDayCount(dayProgress);
    var urges = 0;
    for (final log in sosLogs) {
      final before = log.before;
      final after = log.after;
      if (before != null && after != null && after < before) {
        urges++;
      }
    }

    int? clarityFrom;
    int? clarityTo;
    if (clarityResults.length >= 2) {
      clarityFrom = clarityResults.first.score;
      clarityTo = clarityResults.last.score;
    }

    return PaywallPersonalStats(
      completedDays: completed,
      urgesBeaten: urges,
      hoursFrom: usageHoursFrom,
      hoursTo: usageHoursTo,
      clarityFrom: clarityFrom,
      clarityTo: clarityTo,
    );
  }
}
