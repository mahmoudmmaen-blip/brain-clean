import '../bci_adherence_snapshot.dart';

/// عقد قراءة سجلات الالتزام اليومي من التخزين المحلي (Hive).
abstract interface class BciAdherenceRepository {
  /// يجلب سجلات [RecoveryDayRecord] لآخر 7 أيام من Hive
  /// ويُرجع متوسط [RecoveryDayRecord.dailyBcsScore].
  Future<BciAdherenceSnapshot> fetchLastSevenDaysAdherence();
}
