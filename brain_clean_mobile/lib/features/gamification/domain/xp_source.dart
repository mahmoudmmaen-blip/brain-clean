/// Origin of an XP ledger credit — used for idempotency and daily caps.
enum XpSource {
  dailyTask,
  pomodoro,
  focusSession,
  game,
  diagnostic,
  recovery,
  streakBonus,
  other,
}
