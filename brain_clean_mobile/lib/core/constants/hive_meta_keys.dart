/// Keys stored in the [HiveBoxes.appMeta] box.
abstract final class HiveMetaKeys {
  static const lastResetDate = 'lastResetDate';
  static const hasSeenOnboarding = 'hasSeenOnboarding';
  static const isProUser = 'isProUser';
  static const emotionNotificationsEnabled = 'emotionNotificationsEnabled';
  static const dailyFocusReminderEnabled = 'dailyFocusReminderEnabled';
  static const worryWindowReminderEnabled = 'worryWindowReminderEnabled';
  static const worryWindowReminderHour = 'worryWindowReminderHour';
  static const worryWindowReminderMinute = 'worryWindowReminderMinute';
  static const safaCheckinDismissedUntil = 'safaCheckinDismissedUntil';
  static const safaFirstUsedAt = 'safaFirstUsedAt';
  static const profileDisplayName = 'profileDisplayName';
  static const silenceWinsCount = 'silenceWinsCount';
  static const singleTasksCompletedCount = 'singleTasksCompletedCount';
  static const singleTaskActiveId = 'singleTaskActiveId';
  static const singleTaskActiveLabel = 'singleTaskActiveLabel';
  static const singleTaskIsLocked = 'singleTaskIsLocked';
  static const locale = 'locale';
  static const streakFreezesAvailable = 'streakFreezesAvailable';
  static const streakLastFreezeUsedDate = 'streakLastFreezeUsedDate';
  static const streakIsFrozen = 'streakIsFrozen';
  static const lastKnownBrainLevel = 'lastKnownBrainLevel';
  static const pomodoroSessionsToday = 'pomodoroSessionsToday';
  static const pomodoroSessionsDate = 'pomodoroSessionsDate';
  static const singleTaskCategory = 'singleTaskCategory';
  static const singleTaskDifficulty = 'singleTaskDifficulty';
  static const gameBestPatternMatch = 'gameBestPatternMatch';
  static const gameBestNumberMemory = 'gameBestNumberMemory';
  static const gameBestColorWord = 'gameBestColorWord';
  static const thinkingLog = 'thinking_log';
  static const gameBestNBack = 'gameBestNBack';
  static const gameBestSpeedSort = 'gameBestSpeedSort';

  /// Set to `true` after one-time Hive AES migration ([HiveBootstrap]).
  static const boxesEncryptedV1 = 'boxesEncryptedV1';

  /// Set to `true` after legacy XP is migrated into the signed ledger.
  static const xpLedgerMigratedV1 = 'xpLedgerMigratedV1';

  /// UTC ISO-8601 high-water mark for clock-rollback detection in [XpLedgerRepository].
  static const xpLedgerHighWaterMarkUtc = 'xpLedgerHighWaterMarkUtc';

  /// Authoritative server XP total (from verify-xp); null when never synced online.
  static const serverTotalXp = 'serverTotalXp';

  /// UTC ISO-8601 when [serverTotalXp] was last updated from the server.
  static const serverTotalXpSyncedAt = 'serverTotalXpSyncedAt';

  static const cognitiveVisualResultJson = 'cognitiveVisualResultJson';
  static const cognitiveMemoryResultJson = 'cognitiveMemoryResultJson';
  static const selectedColorThemeId = 'selectedColorThemeId';
}
