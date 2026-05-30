/// BCS bonus from highest N-back level reached.
double nBackBcsBonus(int nReached) => nReached * 3.0;

/// Increments N after [correctStreak] reaches [correctToLevelUp].
int nBackLevelAfterCorrect({
  required int currentN,
  required int correctStreak,
  int correctToLevelUp = 10,
}) {
  if (correctStreak >= correctToLevelUp) return currentN + 1;
  return currentN;
}
