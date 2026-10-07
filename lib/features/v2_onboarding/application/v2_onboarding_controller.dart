import 'package:flutter/foundation.dart';

import '../data/v2_onboarding_repository.dart';
import '../domain/v2_onboarding_answers.dart';
import '../domain/v2_onboarding_progress.dart';
import '../domain/v2_onboarding_state.dart';
import '../domain/v2_onboarding_status.dart';
import '../domain/v2_onboarding_step.dart';

/// Orchestrates short onboarding (welcome → quick setup → plan ready).
class V2OnboardingController extends ChangeNotifier {
  V2OnboardingController({
    required V2OnboardingRepository repository,
    DateTime Function()? clock,
  })  : _repository = repository,
        _clock = clock ?? DateTime.now;

  final V2OnboardingRepository _repository;
  final DateTime Function() _clock;

  V2OnboardingState _state = V2OnboardingState.fresh();
  bool _hydrated = false;
  String? _errorKey;

  V2OnboardingState get state => _state;
  bool get isHydrated => _hydrated;
  String? get errorKey => _errorKey;
  V2OnboardingProgress get progress => _state.progress;

  Future<void> hydrate({String? languageCode}) async {
    try {
      var loaded = await _repository.load();
      if (loaded.status == V2OnboardingStatus.corrupt) {
        loaded = V2OnboardingState.fresh(languageCode: languageCode).copyWith(
          status: V2OnboardingStatus.corrupt,
        );
      } else if (loaded.status == V2OnboardingStatus.notStarted &&
          languageCode != null) {
        loaded = loaded.copyWith(languageCode: languageCode);
      }
      // Migrate legacy in-progress steps onto the short shell.
      if (!loaded.isJourneyComplete) {
        final shell = loaded.currentStep.normalizedForShell;
        if (shell != loaded.currentStep) {
          loaded = loaded.copyWith(currentStep: shell, updatedAt: _now);
          loaded = await _repository.save(loaded);
        }
      }
      _state = loaded;
      _hydrated = true;
      _errorKey = null;
      notifyListeners();
    } catch (e) {
      debugPrint('V2OnboardingController: hydrate failed: $e');
      _state = V2OnboardingState.fresh(languageCode: languageCode).copyWith(
        status: V2OnboardingStatus.corrupt,
      );
      _hydrated = true;
      _errorKey = 'corrupt';
      notifyListeners();
    }
  }

  Future<void> setLanguageCode(String code) async {
    await _persist(
      _state.copyWith(
        languageCode: code,
        status: _state.status == V2OnboardingStatus.notStarted
            ? V2OnboardingStatus.inProgress
            : _state.status,
        updatedAt: _now,
      ),
    );
  }

  Future<void> advanceFromWelcome() async {
    await _goTo(V2OnboardingStep.quickSetup);
  }

  /// Legacy alias — old tests call expectations after welcome.
  Future<void> advanceFromExpectations() async {
    await _goTo(V2OnboardingStep.quickSetup);
  }

  Future<void> saveQuickSetup({
    required V2ScreenHoursBand screenHours,
    required V2OnboardingGoal mainGoal,
    required V2RitualWindow hardestTime,
    V2RitualWindow? reminderTime,
    String? firstName,
  }) async {
    await _persist(
      _state.copyWith(
        screenHours: screenHours,
        mainGoal: mainGoal,
        hardestTime: hardestTime,
        ritualWindow: reminderTime ?? hardestTime,
        firstName: firstName?.trim().isEmpty == true ? null : firstName?.trim(),
        clearFirstName: firstName == null || firstName.trim().isEmpty,
        consentNonMedical: true,
        consentTerms: true,
        privacyAcknowledged: true,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
  }

  Future<bool> advanceFromQuickSetup() async {
    if (!_state.canSubmitQuickSetup) return false;
    await _goTo(V2OnboardingStep.planReady);
    return true;
  }

  Future<void> setConsent({
    required bool nonMedical,
    required bool terms,
    required bool analyticsOptIn,
  }) async {
    await _persist(
      _state.copyWith(
        consentNonMedical: nonMedical,
        consentTerms: terms,
        consentAnalyticsOptIn: analyticsOptIn,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
  }

  Future<bool> advanceFromConsent() async {
    if (!_state.canSubmitConsent) return false;
    await _goTo(V2OnboardingStep.quickSetup);
    return true;
  }

  Future<void> acknowledgePrivacy() async {
    await _persist(
      _state.copyWith(
        privacyAcknowledged: true,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
    await _goTo(V2OnboardingStep.quickSetup);
  }

  Future<void> setRitual(V2RitualWindow? window, {required bool skip}) async {
    await _persist(
      _state.copyWith(
        ritualWindow: window,
        clearRitual: skip || window == null,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
    await _goTo(V2OnboardingStep.planReady);
  }

  Future<void> markReadyForBrainCheck() async {
    if (_state.status == V2OnboardingStatus.completed) {
      return;
    }
    await _persist(
      _state.copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        currentStep: V2OnboardingStep.planReady,
        updatedAt: _now,
      ),
    );
  }

  Future<void> markProfileRevealed({required String sessionId}) async {
    if (_state.isJourneyComplete) return;
    await _persist(
      _state.copyWith(
        currentStep: V2OnboardingStep.planReady,
        profileRevealed: true,
        profileSessionId: sessionId,
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        updatedAt: _now,
      ),
    );
  }

  Future<void> markPlanRevealed({required String planId}) async {
    if (_state.isJourneyComplete) return;
    await _persist(
      _state.copyWith(
        currentStep: V2OnboardingStep.planReady,
        planRevealed: true,
        planId: planId,
        profileRevealed: true,
        brainCheckReady: true,
        status: V2OnboardingStatus.readyForBrainCheck,
        updatedAt: _now,
      ),
    );
  }

  Future<void> markTodayPreviewed({required String planId}) async {
    if (_state.isJourneyComplete) return;
    await _persist(
      _state.copyWith(
        currentStep: V2OnboardingStep.planReady,
        todayPreviewed: true,
        planRevealed: true,
        planId: planId,
        profileRevealed: true,
        brainCheckReady: true,
        status: V2OnboardingStatus.readyForBrainCheck,
        updatedAt: _now,
      ),
    );
  }

  /// First-time journey complete once a plan exists. Idempotent.
  Future<void> markJourneyCompleted({required String planId}) async {
    if (planId.isEmpty) return;
    if (_state.isJourneyComplete && _state.planId == planId) {
      return;
    }
    await _persist(
      _state.copyWith(
        status: V2OnboardingStatus.completed,
        currentStep: V2OnboardingStep.planReady,
        brainCheckReady: true,
        profileRevealed: true,
        planRevealed: true,
        todayPreviewed: true,
        planId: planId,
        journeyCompletedAt: _state.journeyCompletedAt ?? _now,
        updatedAt: _now,
      ),
    );
  }

  Future<void> goBack() async {
    final prev = _state.currentStep.normalizedForShell.previous;
    if (prev == null) return;
    await _persist(
      _state.copyWith(
        currentStep: prev,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
  }

  Future<void> restart({String? languageCode}) async {
    _state = await _repository.restart(
      languageCode: languageCode ?? _state.languageCode,
    );
    _errorKey = null;
    notifyListeners();
  }

  Future<void> clearCorruptAndStart({String? languageCode}) async {
    await restart(languageCode: languageCode);
  }

  Future<void> _goTo(V2OnboardingStep step) async {
    await _persist(
      _state.copyWith(
        currentStep: step,
        status: V2OnboardingStatus.inProgress,
        updatedAt: _now,
      ),
    );
  }

  Future<void> _persist(V2OnboardingState next) async {
    try {
      _state = await _repository.save(next);
      _errorKey = null;
      notifyListeners();
    } catch (e) {
      debugPrint('V2OnboardingController: persist failed: $e');
      _errorKey = 'save_failed';
      notifyListeners();
    }
  }

  DateTime get _now => _clock().toUtc();
}
