import 'package:brain_clean_mobile/features/weekly_report/domain/weekly_report_data.dart';
import 'package:brain_clean_mobile/features/weekly_report/domain/weekly_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyReportService.getMotivationalMessage', () {
    WeeklyReportData base({
      required bool hasBciData,
      required double bciChange,
    }) {
      return WeeklyReportData(
        weekStart: DateTime(2026, 7, 6),
        weekEnd: DateTime(2026, 7, 12),
        avgBciScore: 70,
        bciChange: bciChange,
        hasBciData: hasBciData,
        gamesPlayed: 0,
        streakDays: 0,
        worryEntriesCount: 0,
        dailyChallengesCompleted: 0,
        motivationalMessage: '',
      );
    }

    test('returns first-week copy when no BCI data', () {
      expect(
        WeeklyReportService.getMotivationalMessage(
          base(hasBciData: false, bciChange: 0),
          isArabic: true,
        ),
        'أسبوعك الأول — كل خطوة بتحسب 🚀',
      );
    });

    test('returns strong-week copy when BCI change > 5', () {
      expect(
        WeeklyReportService.getMotivationalMessage(
          base(hasBciData: true, bciChange: 6),
          isArabic: true,
        ),
        'أسبوع قوي — دماغك بيتحسن بوضوح 💚',
      );
    });

    test('returns tough-week copy when BCI change is negative', () {
      expect(
        WeeklyReportService.getMotivationalMessage(
          base(hasBciData: true, bciChange: -2),
          isArabic: true,
        ),
        'أسبوع صعب — وده جزء طبيعي من الرحلة 🤝',
      );
    });
  });

  group('WeeklyReportService.safaMessageForWorryCount', () {
    test('returns tiered Safa copy', () {
      expect(
        WeeklyReportService.safaMessageForWorryCount(3, isArabic: true),
        contains('دفتر القلق'),
      );
      expect(
        WeeklyReportService.safaMessageForWorryCount(0, isArabic: true),
        contains('الأسبوع الجاي'),
      );
    });
  });
}
