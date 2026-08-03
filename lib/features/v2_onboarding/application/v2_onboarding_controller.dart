import 'package:flutter/foundation.dart';

import '../data/v2_onboarding_repository.dart';
import '../domain/v2_onboarding_progress.dart';
import '../domain/v2_onboarding_state.dart';
import '../domain/v2_onboarding_status.dart';
import '../domain/v2_onboarding_step.dart';

/// Orchestrates ONB-01…ONB-06 persistence and resume.
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
    await _goTo(V2OnboardingStep.expectations);
  }

  Future<void> advanceFromExpectations() async {
    await _goTo(V2OnboardingStep.consent);
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
    await _goTo(V2OnboardingStep.privacy);
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
    await _goTo(V2OnboardingStep.ritual);
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
    await _goTo(V2OnboardingStep.checkIntro);
  }

  /// Terminal Slice 5.1 handoff — idempotent.
  Future<void> markReadyForBrainCheck() async {
    if (_state.status == V2OnboardingStatus.readyForBrainCheck ||
        _state.status == V2OnboardingStatus.completed) {
      // Idempotent completion.
      await _persist(
        _state.copyWith(
          brainCheckReady: true,
          currentStep: V2OnboardingStep.checkIntro,
          updatedAt: _now,
        ),
      );
      return;
    }
    await _persist(
      _state.copyWith(
        status: V2OnboardingStatus.readyForBrainCheck,
        brainCheckReady: true,
        currentStep: V2OnboardingStep.checkIntro,
        updatedAt: _now,
      ),
    );
  }

  Future<void> goBack() async {
    final prev = _state.currentStep.previous;
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
