import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_report_data.freezed.dart';

@freezed
class WeeklyReportData with _$WeeklyReportData {
  const factory WeeklyReportData({
    required DateTime weekStart,
    required DateTime weekEnd,
    required double avgBciScore,
    required double bciChange,
    required bool hasBciData,
    required int gamesPlayed,
    String? bestGameName,
    required int streakDays,
    required int worryEntriesCount,
    double? anxietyScore,
    required int dailyChallengesCompleted,
    required String motivationalMessage,
  }) = _WeeklyReportData;
}
