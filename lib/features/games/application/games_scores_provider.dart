import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';

part 'games_scores_provider.g.dart';

class GamesBestScores {
  const GamesBestScores({
    this.patternMatch = 0,
    this.numberMemory = 0,
    this.colorWord = 0,
    this.nBack = 0,
    this.speedSort = 0,
  });

  final int patternMatch;
  final int numberMemory;
  final int colorWord;
  final int nBack;
  final int speedSort;
}

@Riverpod(keepAlive: true)
class GamesBestScoresController extends _$GamesBestScoresController {
  @override
  GamesBestScores build() => _load();

  GamesBestScores _load() {
    try {
      final box = ref.read(appMetaBoxProvider);
      return GamesBestScores(
        patternMatch:
            box.get(HiveMetaKeys.gameBestPatternMatch, defaultValue: 0) as int,
        numberMemory:
            box.get(HiveMetaKeys.gameBestNumberMemory, defaultValue: 0) as int,
        colorWord:
            box.get(HiveMetaKeys.gameBestColorWord, defaultValue: 0) as int,
        nBack: box.get(HiveMetaKeys.gameBestNBack, defaultValue: 0) as int,
        speedSort:
            box.get(HiveMetaKeys.gameBestSpeedSort, defaultValue: 0) as int,
      );
    } catch (_) {
      return const GamesBestScores();
    }
  }

  Future<void> updatePatternBest(int score) async {
    if (score <= state.patternMatch) return;
    state = GamesBestScores(
      patternMatch: score,
      numberMemory: state.numberMemory,
      colorWord: state.colorWord,
      nBack: state.nBack,
      speedSort: state.speedSort,
    );
    await _persist(HiveMetaKeys.gameBestPatternMatch, score);
  }

  Future<void> updateNumberMemoryBest(int digits) async {
    if (digits <= state.numberMemory) return;
    state = GamesBestScores(
      patternMatch: state.patternMatch,
      numberMemory: digits,
      colorWord: state.colorWord,
      nBack: state.nBack,
      speedSort: state.speedSort,
    );
    await _persist(HiveMetaKeys.gameBestNumberMemory, digits);
  }

  Future<void> updateColorWordBest(int score) async {
    if (score <= state.colorWord) return;
    state = GamesBestScores(
      patternMatch: state.patternMatch,
      numberMemory: state.numberMemory,
      colorWord: score,
      nBack: state.nBack,
      speedSort: state.speedSort,
    );
    await _persist(HiveMetaKeys.gameBestColorWord, score);
  }

  Future<void> updateNBackBest(int nLevel) async {
    if (nLevel <= state.nBack) return;
    state = GamesBestScores(
      patternMatch: state.patternMatch,
      numberMemory: state.numberMemory,
      colorWord: state.colorWord,
      nBack: nLevel,
      speedSort: state.speedSort,
    );
    await _persist(HiveMetaKeys.gameBestNBack, nLevel);
  }

  Future<void> updateSpeedSortBest(int correct) async {
    if (correct <= state.speedSort) return;
    state = GamesBestScores(
      patternMatch: state.patternMatch,
      numberMemory: state.numberMemory,
      colorWord: state.colorWord,
      nBack: state.nBack,
      speedSort: correct,
    );
    await _persist(HiveMetaKeys.gameBestSpeedSort, correct);
  }

  Future<void> _persist(String key, int value) async {
    try {
      await ref.read(appMetaBoxProvider).put(key, value);
    } catch (_) {}
  }
}
