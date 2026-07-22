/// Dr. Moneam 30-day recovery protocol bounds.
abstract final class RecoveryProtocolConstants {
  static const int dayCount = 30;
  static const int mandatoryTaskCount = 5;

  /// Habits that count toward [RecoveryDayRecord.dailyBcsScore] (excludes legacy [regulatedSleep]).
  static const int scoredHabitCount = 6;

  /// Equal share per scored habit (nutrition, movement, distraction, mental, sleep, water).
  static const double pointsPerScoredHabit = 100.0 / scoredHabitCount;

  /// BC_score deduction applied when entering the penalty box.
  static const int penaltyBcScoreDeduction = 15;
}
