/// Hive box names — versioned to allow safe migrations later.
abstract final class HiveBoxes {
  static const recoveryProtocol = 'recovery_protocol_v1';
  static const diagnosticPersistence = 'diagnostic_persistence_v1';
  static const emotionLog = 'emotion_log';
  static const dailySnapshots = 'daily_snapshots';
  static const appMeta = 'app_meta';

  // --- الصناديق الجديدة الخاصة بالميزات الاحترافية (Pro Modules) ---
  static const journeyData = 'journey_data_v1';
  static const journalSpaces = 'journal_spaces_v1';
  static const goldenMemories = 'golden_memories_v1';

  /// Append-only signed XP ledger (tamper-evident, client-side HMAC).
  static const xpLedger = 'xp_ledger_v1';

  /// V2 Brain Check draft + completed MeasurementEvent result (local-first).
  static const brainCheck = 'brain_check_v1';

  /// V2 Brain Profile history (ProfilePack append-only, local-first).
  static const brainProfile = 'brain_profile_v1';
}