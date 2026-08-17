import 'package:brain_clean_mobile/features/games/crossword/domain/crossword_logic.dart';
import 'package:brain_clean_mobile/features/games/crossword/domain/crossword_models.dart';
import 'package:flutter_test/flutter_test.dart';

CrosswordClue _clue({
  required CrosswordDirection direction,
  required int startRow,
  required int startCol,
  required int length,
}) =>
    CrosswordClue(
      number: 1,
      direction: direction,
      clueTextAr: 'سؤال',
      clueTextEn: 'clue',
      answer: 'أب',
      startRow: startRow,
      startCol: startCol,
      length: length,
    );

/// 2×2 puzzle: row 0 fully fillable, row 1 has a single blocked cell.
final _puzzle = CrosswordPuzzle(
  id: 'test',
  titleAr: 'اختبار',
  titleEn: 'test',
  grid: const [
    ['أ', 'ب'],
    ['ت', null],
  ],
  clues: const [],
);

void main() {
  group('cellsForClue', () {
    test('across clues walk right-to-left from the start column', () {
      final cells = cellsForClue(
        _clue(
          direction: CrosswordDirection.across,
          startRow: 2,
          startCol: 4,
          length: 3,
        ),
      );

      expect(cells, {
        const CrosswordCell(2, 4),
        const CrosswordCell(2, 3),
        const CrosswordCell(2, 2),
      });
    });

    test('down clues walk downward from the start row', () {
      final cells = cellsForClue(
        _clue(
          direction: CrosswordDirection.down,
          startRow: 1,
          startCol: 0,
          length: 3,
        ),
      );

      expect(cells, {
        const CrosswordCell(1, 0),
        const CrosswordCell(2, 0),
        const CrosswordCell(3, 0),
      });
    });

    test('zero-length clue yields no cells', () {
      final cells = cellsForClue(
        _clue(
          direction: CrosswordDirection.across,
          startRow: 0,
          startCol: 0,
          length: 0,
        ),
      );

      expect(cells, isEmpty);
    });
  });

  group('isCellCorrect', () {
    test('matches the solution letter and trims whitespace', () {
      expect(isCellCorrect(_puzzle, 0, 0, 'أ'), isTrue);
      expect(isCellCorrect(_puzzle, 0, 1, ' ب '), isTrue);
    });

    test('rejects a wrong letter', () {
      expect(isCellCorrect(_puzzle, 0, 0, 'ب'), isFalse);
    });

    test('rejects blocked cells and out-of-bounds coordinates', () {
      expect(isCellCorrect(_puzzle, 1, 1, 'أ'), isFalse);
      expect(isCellCorrect(_puzzle, -1, 0, 'أ'), isFalse);
      expect(isCellCorrect(_puzzle, 0, -1, 'أ'), isFalse);
      expect(isCellCorrect(_puzzle, 2, 0, 'أ'), isFalse);
      expect(isCellCorrect(_puzzle, 0, 2, 'أ'), isFalse);
    });
  });

  group('isPuzzleComplete', () {
    test('true when every fillable cell holds the right letter', () {
      expect(
        isPuzzleComplete(_puzzle, {'0,0': 'أ', '0,1': 'ب', '1,0': 'ت'}),
        isTrue,
      );
    });

    test('blocked cells are ignored even when filled', () {
      expect(
        isPuzzleComplete(
          _puzzle,
          {'0,0': 'أ', '0,1': 'ب', '1,0': 'ت', '1,1': 'ث'},
        ),
        isTrue,
      );
    });

    test('false when a cell is missing or wrong', () {
      expect(isPuzzleComplete(_puzzle, {'0,0': 'أ', '0,1': 'ب'}), isFalse);
      expect(
        isPuzzleComplete(_puzzle, {'0,0': 'أ', '0,1': 'ب', '1,0': 'ج'}),
        isFalse,
      );
      expect(isPuzzleComplete(_puzzle, const {}), isFalse);
    });
  });
}
