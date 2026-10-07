import 'package:brain_clean_mobile/features/daily_session/domain/home_dashboard_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Day 1 of 30 program bar is about 3%', () {
    const m = HomeDashboardMetrics(
      focusPercent: 54,
      focusImprovementPercent: 0,
      streakDays: 0,
      exercisesToday: 0,
      programDay: 1,
      programTotalDays: 30,
    );
    expect(m.programProgress, closeTo(1 / 30, 0.0001));
    expect(m.programProgress, lessThan(0.05));
    // Recovery score must not drive the day bar.
    expect(m.focusProgress, closeTo(0.54, 0.0001));
    expect(m.programProgress, isNot(closeTo(m.focusProgress, 0.01)));
  });
}
