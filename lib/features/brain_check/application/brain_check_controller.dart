import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/brain_check_local_repository.dart';
import '../domain/brain_check.dart';
import '../domain/brain_check_answer.dart';
import '../domain/brain_check_item_bank.dart';
import '../domain/brain_check_mode.dart';
import '../domain/brain_check_phase.dart';
import '../domain/brain_check_progress.dart';
import '../domain/brain_check_question.dart';
import '../domain/brain_check_result.dart';
import '../domain/brain_check_validation.dart';
import '../domain/measurement_event.dart';
import '../domain/recovery_score_bridge.dart';

/// Orchestrates Brain Check progression, persistence, resume, and restart.
///
/// Offline / local-first: every accepted answer is persisted before advancing.
class BrainCheckController extends ChangeNotifier {
  BrainCheckController({
    required BrainCheckLocalRepository repository,
    RecoveryScoreBridge scoreBridge = const PendingRecoveryScoreBridge(),
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _repository = repository,
        _scoreBridge = scoreBridge,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final BrainCheckLocalRepository _repository;
  final RecoveryScoreBridge _scoreBridge;
  final Uuid _uuid;
  final DateTime Function() _clock;

  BrainCheckProgress _progress = BrainCheckProgress.empty();
  BrainCheckResult? _result;
  bool _hydrated = false;
  String? _lastSaveError;
  BrainCheckValidationResult? _lastValidation;

  BrainCheckProgress get progress => _progress;
  BrainCheckResult? get result => _result;
  bool get isHydrated => _hydrated;
  String? get lastSaveError => _lastSaveError;
  BrainCheckValidationResult? get lastValidation => _lastValidation;

  BrainCheck get snapshot => BrainCheck(progress: _progress, result: _result);

  BrainCheckQuestion? get currentQuestion => snapshot.currentQuestion;

  /// Cold-start hydrate. Incomplete drafts open the resume gate (CHK-02C).
  Future<void> hydrate() async {
    try {
      final draft = await _repository.loadDraft();
      final storedResult = await _repository.loadResult();
      _result = storedResult;

      if (draft != null &&
          draft.hasDraftProgress &&
          draft.phase != BrainCheckPhase.completed) {
        _progress = draft.copyWith(phase: BrainCheckPhase.resumeGate);
      } else if (storedResult != null) {
        _progress = BrainCheckProgress(
          mode: storedResult.mode,
          phase: BrainCheckPhase.completed,
          currentQuestionIndex: 0,
          currentSectionIndex: 0,
          answers: const {},
          source: storedResult.source,
          startedAt: storedResult.completedAt,
          updatedAt: storedResult.completedAt,
        );
      } else {
        _progress = BrainCheckProgress.empty();
      }
      _hydrated = true;
      _lastSaveError = null;
      notifyListeners();
    } catch (e) {
      debugPrint('BrainCheckController: hydrate failed: $e');
      _progress = BrainCheckProgress.empty();
      _hydrated = true;
      notifyListeners();
    }
  }

  /// CHK-01 → start a fresh path (wipes incomplete draft).
  Future<BrainCheckValidationResult> start({
    BrainCheckMode mode = BrainCheckMode.lite,
    String? source,
  }) async {
    final now = _clock().toUtc();
    _result = null;
    _progress = BrainCheckProgress(
      mode: mode,
      phase: BrainCheckPhase.item,
      currentQuestionIndex: 0,
      currentSectionIndex: 0,
      answers: const {},
      source: source,
      startedAt: now,
      updatedAt: now,
    );
    _lastValidation = BrainCheckValidationResult.ok;
    await _persistDraft();
    notifyListeners();
    return _lastValidation!;
  }

  /// Enter intro without wiping an existing completed result.
  Future<void> showIntro({
    BrainCheckMode mode = BrainCheckMode.lite,
    String? source,
  }) async {
    final now = _clock().toUtc();
    _progress = BrainCheckProgress(
      mode: mode,
      phase: BrainCheckPhase.intro,
      currentQuestionIndex: 0,
      currentSectionIndex: 0,
      answers: const {},
      source: source,
      startedAt: now,
      updatedAt: now,
    );
    await _persistDraft();
    notifyListeners();
  }

  /// Continue an incomplete draft from the resume gate.
  Future<BrainCheckValidationResult> resume() async {
    final draft = await _repository.loadDraft();
    if (draft == null || !draft.hasDraftProgress) {
      _lastValidation = const BrainCheckValidationResult(
        code: BrainCheckValidationCode.noDraft,
        messageEn: 'No saved Brain Check to resume.',
        messageAr: 'لا يوجد فحص دماغ محفوظ للاستكمال.',
      );
      notifyListeners();
      return _lastValidation!;
    }

    final phase = draft.phase == BrainCheckPhase.resumeGate ||
            draft.phase == BrainCheckPhase.empty ||
            draft.phase == BrainCheckPhase.intro
        ? BrainCheckPhase.item
        : draft.phase;

    _progress = draft.copyWith(
      phase: phase,
      updatedAt: _clock().toUtc(),
    );
    _lastValidation = BrainCheckValidationResult.ok;
    await _persistDraft();
    notifyListeners();
    return _lastValidation!;
  }

  /// Start over — requires explicit confirmation (CHK-02C).
  Future<BrainCheckValidationResult> restart({required bool confirmed}) async {
    final gate = BrainCheckValidation.validateRestart(confirmed: confirmed);
    if (!gate.isOk) {
      _lastValidation = gate;
      notifyListeners();
      return gate;
    }

    final mode = _progress.mode;
    final source = _progress.source;
    await _repository.clearDraft();
    _result = null;
    _lastValidation = await start(mode: mode, source: source);
    return _lastValidation!;
  }

  /// Persist an answer and advance (autosave).
  Future<BrainCheckValidationResult> answerCurrent(int? value) async {
    if (_progress.phase == BrainCheckPhase.completed) {
      _lastValidation = const BrainCheckValidationResult(
        code: BrainCheckValidationCode.alreadyComplete,
        messageEn: 'Brain Check is already complete.',
        messageAr: 'فحص الدماغ مكتمل بالفعل.',
      );
      notifyListeners();
      return _lastValidation!;
    }
    if (_progress.phase != BrainCheckPhase.item) {
      _lastValidation = const BrainCheckValidationResult(
        code: BrainCheckValidationCode.notInProgress,
        messageEn: 'No active question to answer.',
        messageAr: 'لا يوجد سؤال نشط للإجابة.',
      );
      notifyListeners();
      return _lastValidation!;
    }

    final question = currentQuestion;
    final validation = BrainCheckValidation.validateAnswer(
      question: question,
      value: value,
      expectedQuestionId: question?.id,
    );
    if (!validation.isOk || question == null || value == null) {
      _lastValidation = validation;
      notifyListeners();
      return validation;
    }

    final now = _clock().toUtc();
    final nextAnswers = Map<String, BrainCheckAnswer>.from(_progress.answers);
    nextAnswers[question.id] = BrainCheckAnswer(
      questionId: question.id,
      value: value,
      answeredAt: now,
    );

    final questions = BrainCheckItemBank.questionsFor(_progress.mode);
    final nextIndex = _progress.currentQuestionIndex + 1;

    if (nextIndex >= questions.length) {
      _progress = _progress.copyWith(
        answers: Map.unmodifiable(nextAnswers),
        phase: BrainCheckPhase.completion,
        currentQuestionIndex: questions.length,
        currentSectionIndex:
            BrainCheckItemBank.sectionIndexForQuestion(_progress.mode, questions.length - 1),
        updatedAt: now,
      );
      _lastValidation = BrainCheckValidationResult.ok;
      await _persistDraft();
      notifyListeners();
      return _lastValidation!;
    }

    // Full-mode micro-break when entering a new section.
    if (_progress.mode == BrainCheckMode.full &&
        BrainCheckItemBank.isSectionBoundaryStart(_progress.mode, nextIndex)) {
      final sectionIndex =
          BrainCheckItemBank.sectionIndexForQuestion(_progress.mode, nextIndex);
      _progress = _progress.copyWith(
        answers: Map.unmodifiable(nextAnswers),
        phase: BrainCheckPhase.sectionBreak,
        currentQuestionIndex: nextIndex,
        currentSectionIndex: sectionIndex,
        updatedAt: now,
      );
      _lastValidation = BrainCheckValidationResult.ok;
      await _persistDraft();
      notifyListeners();
      return _lastValidation!;
    }

    final sectionIndex =
        BrainCheckItemBank.sectionIndexForQuestion(_progress.mode, nextIndex);
    _progress = _progress.copyWith(
      answers: Map.unmodifiable(nextAnswers),
      phase: BrainCheckPhase.item,
      currentQuestionIndex: nextIndex,
      currentSectionIndex: sectionIndex,
      updatedAt: now,
    );
    _lastValidation = BrainCheckValidationResult.ok;
    await _persistDraft();
    notifyListeners();
    return _lastValidation!;
  }

  /// Continue after CHK-02B micro-break.
  Future<void> continueAfterBreak() async {
    if (_progress.phase != BrainCheckPhase.sectionBreak) return;
    _progress = _progress.copyWith(
      phase: BrainCheckPhase.item,
      updatedAt: _clock().toUtc(),
    );
    await _persistDraft();
    notifyListeners();
  }

  /// Move back one answered question when possible.
  Future<BrainCheckValidationResult> goBack() async {
    if (_progress.phase == BrainCheckPhase.sectionBreak) {
      final backIndex = _progress.currentQuestionIndex > 0
          ? _progress.currentQuestionIndex - 1
          : 0;
      _progress = _progress.copyWith(
        phase: BrainCheckPhase.item,
        currentQuestionIndex: backIndex,
        currentSectionIndex: BrainCheckItemBank.sectionIndexForQuestion(
          _progress.mode,
          backIndex,
        ),
        updatedAt: _clock().toUtc(),
      );
      await _persistDraft();
      notifyListeners();
      return BrainCheckValidationResult.ok;
    }

    if (_progress.phase != BrainCheckPhase.item) {
      return const BrainCheckValidationResult(
        code: BrainCheckValidationCode.notInProgress,
        messageEn: 'Cannot go back from this step.',
        messageAr: 'لا يمكن الرجوع من هذه الخطوة.',
      );
    }

    if (_progress.currentQuestionIndex <= 0) {
      return BrainCheckValidationResult.ok;
    }

    final backIndex = _progress.currentQuestionIndex - 1;
    _progress = _progress.copyWith(
      currentQuestionIndex: backIndex,
      currentSectionIndex: BrainCheckItemBank.sectionIndexForQuestion(
        _progress.mode,
        backIndex,
      ),
      updatedAt: _clock().toUtc(),
    );
    await _persistDraft();
    notifyListeners();
    return BrainCheckValidationResult.ok;
  }

  /// CHK-04 → commit MeasurementEvent + placeholder score; clear draft.
  Future<BrainCheckValidationResult> complete({String? languageCode}) async {
    if (_progress.phase != BrainCheckPhase.completion &&
        !_allQuestionsAnswered()) {
      _lastValidation = const BrainCheckValidationResult(
        code: BrainCheckValidationCode.notInProgress,
        messageEn: 'Finish all questions before completing.',
        messageAr: 'أكمِل كل الأسئلة قبل الإنهاء.',
      );
      notifyListeners();
      return _lastValidation!;
    }

    final questions = BrainCheckItemBank.questionsFor(_progress.mode);
    for (final question in questions) {
      if (!_progress.answers.containsKey(question.id)) {
        _lastValidation = const BrainCheckValidationResult(
          code: BrainCheckValidationCode.emptyAnswer,
          messageEn: 'Some answers are missing.',
          messageAr: 'بعض الإجابات ناقصة.',
        );
        notifyListeners();
        return _lastValidation!;
      }
    }

    final now = _clock().toUtc();
    final answerValues = <String, int>{
      for (final entry in _progress.answers.entries) entry.key: entry.value.value,
    };
    final sectionIds = BrainCheckItemBank.sectionsFor(_progress.mode)
        .map((s) => s.id)
        .toList(growable: false);

    final event = MeasurementEvent(
      id: _uuid.v4(),
      mode: _progress.mode,
      capturedAt: now,
      answers: answerValues,
      sectionIds: sectionIds,
      source: _progress.source,
      languageCode: languageCode,
    );

    final scorePlaceholder = _scoreBridge.compute(event);
    final completed = BrainCheckResult(
      mode: _progress.mode,
      completedAt: now,
      answers: answerValues,
      measurementEvent: event,
      scorePlaceholder: scorePlaceholder,
      source: _progress.source,
      sessionId: event.id,
    );

    try {
      await _repository.saveResult(completed);
      await _repository.clearDraft();
      _result = completed;
      _progress = _progress.copyWith(
        phase: BrainCheckPhase.completed,
        updatedAt: now,
      );
      _lastSaveError = null;
      _lastValidation = BrainCheckValidationResult.ok;
      notifyListeners();
      return _lastValidation!;
    } catch (e) {
      _lastSaveError = e.toString();
      _lastValidation = const BrainCheckValidationResult(
        code: BrainCheckValidationCode.notInProgress,
        messageEn: 'Could not save your Brain Check. Please try again.',
        messageAr: 'تعذّر حفظ فحص الدماغ. حاول مرة أخرى.',
      );
      notifyListeners();
      return _lastValidation!;
    }
  }

  bool _allQuestionsAnswered() {
    final questions = BrainCheckItemBank.questionsFor(_progress.mode);
    if (questions.isEmpty) return false;
    for (final question in questions) {
      if (!_progress.answers.containsKey(question.id)) return false;
    }
    return true;
  }

  Future<void> _persistDraft() async {
    try {
      await _repository.saveDraft(_progress);
      _lastSaveError = null;
    } catch (e) {
      _lastSaveError = e.toString();
      debugPrint('BrainCheckController: autosave failed: $e');
    }
  }
}
