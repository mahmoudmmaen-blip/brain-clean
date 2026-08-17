import 'brain_check_phase.dart';
import 'brain_check_progress.dart';
import 'brain_check_question.dart';
import 'brain_check_result.dart';
import 'brain_check_section.dart';
import 'brain_check_item_bank.dart';
import 'brain_check_mode.dart';

export 'brain_check_answer.dart';
export 'brain_check_item_bank.dart';
export 'brain_check_mode.dart';
export 'brain_check_phase.dart';
export 'brain_check_progress.dart';
export 'brain_check_question.dart';
export 'brain_check_result.dart';
export 'brain_check_scale.dart';
export 'brain_check_section.dart';
export 'brain_check_validation.dart';
export 'measurement_event.dart';
export 'recovery_score_bridge.dart';

/// Domain aggregate for a Brain Check session (models + bank helpers).
class BrainCheck {
  const BrainCheck({
    required this.progress,
    this.result,
  });

  final BrainCheckProgress progress;
  final BrainCheckResult? result;

  BrainCheckMode get mode => progress.mode;
  BrainCheckPhase get phase => progress.phase;
  bool get isEmpty => progress.phase == BrainCheckPhase.empty;
  bool get isComplete => progress.isComplete || result != null;

  List<BrainCheckSection> get sections =>
      BrainCheckItemBank.sectionsFor(progress.mode);

  List<BrainCheckQuestion> get questions =>
      BrainCheckItemBank.questionsFor(progress.mode);

  BrainCheckQuestion? get currentQuestion {
    final list = questions;
    final index = progress.currentQuestionIndex;
    if (index < 0 || index >= list.length) return null;
    return list[index];
  }

  BrainCheckSection? get currentSection {
    final list = sections;
    final index = progress.currentSectionIndex;
    if (index < 0 || index >= list.length) return null;
    return list[index];
  }

  int get totalQuestions => questions.length;

  double get fractionComplete {
    if (totalQuestions == 0) return 0;
    return progress.answeredCount / totalQuestions;
  }
}
