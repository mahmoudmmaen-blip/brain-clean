import '../../../core/constants/bci_score_constants.dart';
import '../../recovery/domain/recovery_day_record.dart';
import '../../recovery/domain/recovery_protocol_state.dart';
import 'bci_adherence_snapshot.dart';

/// منطق domain خالص لحساب متوسط الالتزام من سجلات التعافي.
abstract final class BciAdherenceCalculator {
  BciAdherenceCalculator._();

  /// يستخرج آخر [BciScoreConstants.adherenceWindowDays] أيام من حالة البروتوكول.
  static BciAdherenceSnapshot fromProtocolState(RecoveryProtocolState state) {
    final records = lastSevenDayRecords(state);
    return BciAdherenceSnapshot(
      records: records,
      averageDailyBcsScore: averageDailyBcsScore(records),
      daysSampled: records.length,
    );
  }

  /// يُرجع سجلات آخر 7 أيام بروتوكول (أو أقل إذا لم يمضِِ أسبوع كامل).
  static List<RecoveryDayRecord> lastSevenDayRecords(
    RecoveryProtocolState state,
  ) {
    final currentDay = state.currentProtocolDay;
    if (currentDay < 1) return const [];

    final window = BciScoreConstants.adherenceWindowDays;
    final startDay = (currentDay - window + 1).clamp(1, currentDay);

    final records = <RecoveryDayRecord>[];
    for (var day = startDay; day <= currentDay; day++) {
      records.add(state.dayRecord(day));
    }
    return records;
  }

  /// يحسب متوسط [RecoveryDayRecord.dailyBcsScore] لقائمة السجلات (0–100).
  static double averageDailyBcsScore(List<RecoveryDayRecord> records) {
    if (records.isEmpty) return 0;
    var sum = 0.0;
    for (final record in records) {
      sum += record.dailyBcsScore;
    }
    return (sum / records.length).clamp(0.0, 100.0);
  }
}
