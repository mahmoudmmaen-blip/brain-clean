import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../core/providers/locale_provider.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import 'domain/crossword_logic.dart';
import 'domain/crossword_models.dart';
import 'domain/crossword_puzzles.dart';

const crosswordScreenKey = Key('crossword_screen');
const crosswordGridKey = Key('crossword_grid');

/// Arabic crossword puzzle player.
class CrosswordScreen extends ConsumerStatefulWidget {
  const CrosswordScreen({super.key, this.initialPuzzleIndex = 0});

  final int initialPuzzleIndex;

  @override
  ConsumerState<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends ConsumerState<CrosswordScreen>
    with SingleTickerProviderStateMixin {
  late CrosswordPuzzle _puzzle;
  late TabController _tabController;
  final Map<String, String> _entries = {};
  CrosswordClue? _selectedClue;
  Set<CrosswordCell> _selectedCells = {};
  int? _selectedRow;
  int? _selectedCol;
  late DateTime _startedAt;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final index = widget.initialPuzzleIndex.clamp(
      0,
      crosswordPuzzles.length - 1,
    );
    _puzzle = crosswordPuzzles[index];
    _tabController = TabController(length: 2, vsync: this);
    _startedAt = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectClue(CrosswordClue clue) {
    setState(() {
      _selectedClue = clue;
      _selectedCells = cellsForClue(clue);
      _selectedRow = clue.startRow;
      _selectedCol = clue.startCol;
    });
  }

  void _onCellTap(int row, int col) {
    if (_puzzle.grid[row][col] == null) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _selectedCells = {CrosswordCell(row, col)};
      _selectedClue = null;
    });
  }

  void _onLetterChanged(String value) {
    if (_selectedRow == null || _selectedCol == null) return;
    final key = '${_selectedRow!},${_selectedCol!}';
    setState(() {
      if (value.isEmpty) {
        _entries.remove(key);
      } else {
        _entries[key] = value[value.length - 1];
      }
    });
    _checkCompletion();
  }

  void _checkCompletion() {
    if (!isPuzzleComplete(_puzzle, _entries)) return;
    final elapsed = DateTime.now().difference(_startedAt);
    ref.read(bcScoreProvider.notifier).applyBonus(crosswordCompleteBonus);
    if (elapsed < crosswordTimeBonusThreshold) {
      ref.read(bcScoreProvider.notifier).applyBonus(crosswordTimeBonus);
    }
    setState(() => _completed = true);
    final isAr = ref.read(localeProvider).languageCode == 'ar';
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'أكملت اللغز في $minutes:${seconds.toString().padLeft(2, '0')}!'
              : 'Puzzle complete in $minutes:${seconds.toString().padLeft(2, '0')}!',
        ),
        backgroundColor: const Color(0xFF1D9E75),
      ),
    );
  }

  int? _clueNumberAt(int row, int col) {
    for (final clue in _puzzle.clues) {
      final cells = cellsForClue(clue);
      if (cells.contains(CrosswordCell(row, col))) {
        final isStart = clue.direction == CrosswordDirection.across
            ? row == clue.startRow && col == clue.startCol
            : row == clue.startRow && col == clue.startCol;
        if (isStart) return clue.number;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final across = _puzzle.clues
        .where((c) => c.direction == CrosswordDirection.across)
        .toList();
    final down = _puzzle.clues
        .where((c) => c.direction == CrosswordDirection.down)
        .toList();

    return Scaffold(
      key: crosswordScreenKey,
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Text(_puzzle.title(isAr)),
        actions: const [LanguageToggleButton()],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.crosswordTabAcross),
            Tab(text: loc.crosswordTabDown),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                key: crosswordGridKey,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _puzzle.cols,
                ),
                itemCount: _puzzle.rows * _puzzle.cols,
                itemBuilder: (context, index) {
                  final row = index ~/ _puzzle.cols;
                  final col = index % _puzzle.cols;
                  final solution = _puzzle.grid[row][col];
                  if (solution == null) {
                    return const ColoredBox(color: Color(0xFF0D1117));
                  }
                  final cell = CrosswordCell(row, col);
                  final isSelected = _selectedCells.contains(cell) ||
                      (_selectedRow == row && _selectedCol == col);
                  final key = '$row,$col';
                  final letter = _entries[key] ?? '';
                  final correct = letter.isNotEmpty &&
                      isCellCorrect(_puzzle, row, col, letter);
                  final wrong = letter.isNotEmpty && !correct;
                  Color bg = const Color(0xFF161B22);
                  if (correct && _completed) {
                    bg = const Color(0x331D9E75);
                  } else if (wrong) {
                    bg = const Color(0x33EF4444);
                  }
                  return GestureDetector(
                    onTap: () => _onCellTap(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1D9E75)
                              : const Color(0xFF30363D),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (_clueNumberAt(row, col) != null)
                            Positioned(
                              left: 2,
                              top: 2,
                              child: Text(
                                '${_clueNumberAt(row, col)}',
                                style: const TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          Center(
                            child: Text(
                              letter,
                              style: const TextStyle(
                                color: Color(0xFFE6EDF3),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_selectedRow != null && _selectedCol != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  autofocus: true,
                  onChanged: _onLetterChanged,
                  style: const TextStyle(color: Color(0xFFE6EDF3)),
                  decoration: InputDecoration(
                    hintText: loc.crosswordEnterLetter,
                    filled: true,
                    fillColor: const Color(0xFF161B22),
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ClueList(
                  clues: across,
                  isAr: isAr,
                  selected: _selectedClue,
                  onTap: _selectClue,
                ),
                _ClueList(
                  clues: down,
                  isAr: isAr,
                  selected: _selectedClue,
                  onTap: _selectClue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClueList extends StatelessWidget {
  const _ClueList({
    required this.clues,
    required this.isAr,
    required this.selected,
    required this.onTap,
  });

  final List<CrosswordClue> clues;
  final bool isAr;
  final CrosswordClue? selected;
  final ValueChanged<CrosswordClue> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: clues.length,
      itemBuilder: (context, index) {
        final clue = clues[index];
        final isSelected = selected == clue;
        return ListTile(
          selected: isSelected,
          selectedTileColor: const Color(0x331D9E75),
          title: Text(
            '${clue.number}. ${clue.clueText(isAr)}',
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF1D9E75)
                  : const Color(0xFFE6EDF3),
            ),
          ),
          onTap: () => onTap(clue),
        );
      },
    );
  }
}
