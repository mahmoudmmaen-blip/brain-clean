import 'crossword_models.dart';

/// Returns all cells belonging to [clue] (RTL across, LTR down).
Set<CrosswordCell> cellsForClue(CrosswordClue clue) {
  final cells = <CrosswordCell>{};
  for (var i = 0; i < clue.length; i++) {
    if (clue.direction == CrosswordDirection.across) {
      cells.add(CrosswordCell(clue.startRow, clue.startCol - i));
    } else {
      cells.add(CrosswordCell(clue.startRow + i, clue.startCol));
    }
  }
  return cells;
}

/// Whether [letter] matches the solution at [row],[col].
bool isCellCorrect(
  CrosswordPuzzle puzzle,
  int row,
  int col,
  String letter,
) {
  if (row < 0 || col < 0 || row >= puzzle.rows || col >= puzzle.cols) {
    return false;
  }
  final expected = puzzle.grid[row][col];
  if (expected == null) return false;
  return letter.trim() == expected;
}

/// True when every fillable cell has the correct letter in [entries].
bool isPuzzleComplete(
  CrosswordPuzzle puzzle,
  Map<String, String> entries,
) {
  for (var r = 0; r < puzzle.rows; r++) {
    for (var c = 0; c < puzzle.cols; c++) {
      final expected = puzzle.grid[r][c];
      if (expected == null) continue;
      final key = '$r,$c';
      if (entries[key] != expected) return false;
    }
  }
  return true;
}

/// Time bonus threshold — complete under 5 minutes.
const crosswordTimeBonusThreshold = Duration(minutes: 5);

const double crosswordCompleteBonus = 20;
const double crosswordTimeBonus = 5;
