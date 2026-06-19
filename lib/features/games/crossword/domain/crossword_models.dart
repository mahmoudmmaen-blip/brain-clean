/// Clue direction on the crossword grid.
enum CrosswordDirection {
  across,
  down,
}

/// A single crossword clue.
class CrosswordClue {
  const CrosswordClue({
    required this.number,
    required this.direction,
    required this.clueTextAr,
    required this.clueTextEn,
    required this.answer,
    required this.startRow,
    required this.startCol,
    required this.length,
  });

  final int number;
  final CrosswordDirection direction;
  final String clueTextAr;
  final String clueTextEn;
  final String answer;
  final int startRow;
  final int startCol;
  final int length;

  String clueText(bool isArabic) => isArabic ? clueTextAr : clueTextEn;
}

/// Static crossword puzzle definition.
class CrosswordPuzzle {
  const CrosswordPuzzle({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.grid,
    required this.clues,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final List<List<String?>> grid;
  final List<CrosswordClue> clues;

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid.first.length;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
}

/// Grid cell coordinate.
class CrosswordCell {
  const CrosswordCell(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is CrosswordCell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}
