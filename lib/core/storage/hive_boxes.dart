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
}