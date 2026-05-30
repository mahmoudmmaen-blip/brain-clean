/// Pattern match score 0–100 from correct/total cells.
double patternMatchScore({required int correctCells, required int totalCells}) {
  if (totalCells <= 0) return 0;
  return (correctCells / totalCells) * 100;
}

/// BCS bonus from pattern match score.
double patternMatchBcsBonus(double scorePercent) => (scorePercent / 100) * 8;

/// BCS bonus from number memory max sequence length.
double numberMemoryBcsBonus(int maxDigits) {
  if (maxDigits < 3) return 0;
  return (maxDigits - 2) * 2.0;
}

/// BCS bonus from color-word Stroop test.
double colorWordBcsBonus({required int correct, required int totalRounds}) {
  if (totalRounds <= 0) return 0;
  return (correct / totalRounds) * 6;
}
