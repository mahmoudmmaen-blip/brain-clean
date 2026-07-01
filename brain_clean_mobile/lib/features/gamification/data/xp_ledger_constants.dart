import '../../games/domain/game_scoring.dart';
import '../../games/domain/n_back_logic.dart';
import '../../games/domain/speed_sort_logic.dart';
import '../../games/crossword/domain/crossword_logic.dart';
import '../../focus/domain/focused_thinking_logic.dart';
import '../../focus/domain/task_category.dart';
import '../../pomodoro/domain/pomodoro_logic.dart';
import '../../diagnostic/presentation/visual_cognitive_scorer.dart';
import '../domain/xp_source.dart';

/// Per-source daily XP ceilings (client first-line guards).
abstract final class XpLedgerConstants {
  static const legacyMigrationRefId = 'legacy_migration';

  static const dailyCapDailyTask = 60;
  static const dailyCapPomodoro = 50;
  static const dailyCapFocusSession = 120;
  static const dailyCapGame = 100;
  static const dailyCapDiagnostic = 40;
  static const dailyCapRecovery = 40;
  static const dailyCapStreakBonus = 30;

  static int dailyCapFor(XpSource source) {
    switch (source) {
      case XpSource.dailyTask:
        return dailyCapDailyTask;
      case XpSource.pomodoro:
        return dailyCapPomodoro;
      case XpSource.focusSession:
        return dailyCapFocusSession;
      case XpSource.game:
        return dailyCapGame;
      case XpSource.diagnostic:
        return dailyCapDiagnostic;
      case XpSource.recovery:
        return dailyCapRecovery;
      case XpSource.streakBonus:
        return dailyCapStreakBonus;
      case XpSource.other:
        return 1 << 30;
    }
  }

  /// UTC calendar day key for idempotency windows.
  static String utcDayKey(DateTime utc) {
    final d = utc.toUtc();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// Max achievable XP from game scoring for plausibility checks.
  static int maxPlausibleGameXp(String? refId) {
    if (refId == null || refId.isEmpty) return dailyCapGame;
    final gameId = refId.split(':').first;
    switch (gameId) {
      case 'pattern_match':
        return patternMatchBcsBonus(100).ceil();
      case 'number_memory':
        return numberMemoryBcsBonus(20).ceil();
      case 'color_word':
        return colorWordBcsBonus(correct: 20, totalRounds: 20).ceil();
      case 'n_back':
        return nBackBcsBonus(12).ceil();
      case 'speed_sort':
        return speedSortBcsBonus(30).ceil();
      case 'crossword':
        return (crosswordCompleteBonus + crosswordTimeBonus).ceil();
      default:
        return dailyCapGame;
    }
  }

  static int maxPlausibleForSource(XpSource source, {String? refId}) {
    switch (source) {
      case XpSource.game:
        return maxPlausibleGameXp(refId);
      case XpSource.focusSession:
        return 30;
      case XpSource.pomodoro:
        return pomodoroFocusBonus(1).ceil();
      case XpSource.diagnostic:
        return VisualCognitiveScorer.cognitiveBonus(15).ceil();
      case XpSource.dailyTask:
        return taskCompletionBonus(TaskCategory.mental, 3).ceil();
      default:
        return dailyCapFor(source);
    }
  }
}
