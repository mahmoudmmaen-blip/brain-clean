import 'package:brain_clean_mobile/features/focus/domain/focused_thinking_logic.dart';
import 'package:brain_clean_mobile/features/games/crossword/domain/crossword_logic.dart';
import 'package:brain_clean_mobile/features/games/crossword/domain/crossword_models.dart';
import 'package:brain_clean_mobile/features/games/crossword/domain/crossword_puzzles.dart';
import 'package:brain_clean_mobile/features/games/domain/n_back_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Focused thinking BCS bonus', () {
    test('focusCheckScore 0.9 yields bonus 15', () {
      expect(focusedThinkingBcsBonus(0.9), 15);
    });

    test('focusCheckScore 0.5 yields bonus 5', () {
      expect(focusedThinkingBcsBonus(0.5), 5);
    });
  });

  group('Crossword clue selection', () {
    test('tap clue selects correct cells in grid', () {
      final puzzle = crosswordPuzzles.first;
      final clue = puzzle.clues.first;
      final cells = cellsForClue(clue);
      expect(cells, isNotEmpty);
      for (final cell in cells) {
        expect(puzzle.grid[cell.row][cell.col], isNotNull);
      }
      expect(cells.length, clue.length);
    });
  });

  group('N-Back level progression', () {
    test('10 correct at N=1 advances N to 2', () {
      expect(
        nBackLevelAfterCorrect(currentN: 1, correctStreak: 10),
        2,
      );
    });

    test('BCS bonus equals N reached times 3', () {
      expect(nBackBcsBonus(2), 6);
    });
  });
}
