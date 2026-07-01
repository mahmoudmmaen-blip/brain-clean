import '../../recovery/domain/recovery_day_record.dart';

/// نتيجة جلب آخر 7 أيام من سجلات [RecoveryDayRecord] وحساب متوسط BCS.
class BciAdherenceSnapshot {
  const BciAdherenceSnapshot({
    required this.records,
    required this.averageDailyBcsScore,
    required this.daysSampled,
  });

  /// سجلات الأيام المستخدمة في الحساب (مرتبة تصاعدياً حسب [RecoveryDayRecord.dayIndex]).
  final List<RecoveryDayRecord> records;

  /// متوسط [RecoveryDayRecord.dailyBcsScore] للسجلات أعلاه (0–100).
  final double averageDailyBcsScore;

  /// عدد الأيام التي دخلت فعلياً في المتوسط (1–7).
  final int daysSampled;

  static const empty = BciAdherenceSnapshot(
    records: [],
    averageDailyBcsScore: 0,
    daysSampled: 0,
  );

  /// درجة الالتزام الجاهزة للدمج في معادلة BCI.
  double get adherenceScore => averageDailyBcsScore.clamp(0.0, 100.0);
}
