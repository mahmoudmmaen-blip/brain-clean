/// BCS bonus from speed-sort correct count (max 15).
double speedSortBcsBonus(int correctCount) =>
    (correctCount / 2).clamp(0, 15).toDouble();
