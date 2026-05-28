import 'dart:async';

/// Blocks questionnaire taps for the duration of a question slide transition.
///
/// Used by [BrainRotQuestionPage] to ignore duplicate نعم/لا input while
/// [AnimatedSwitcher] is animating between prompts.
final class SlideLockMechanism {
  SlideLockMechanism({required Duration slideDuration})
      : _slideDuration = slideDuration;

  final Duration _slideDuration;
  Timer? _timer;
  bool _locked = false;

  /// True while slide animation is active — all answer taps must be ignored.
  bool get isLocked => _locked;

  /// Engages the lock until [slideDuration] elapses, then releases automatically.
  void acquire(void Function() onLockChanged) {
    _timer?.cancel();
    _locked = true;
    onLockChanged();
    _timer = Timer(_slideDuration, () => release(onLockChanged));
  }

  /// Releases the lock immediately (e.g. widget dispose or navigation cancel).
  void release(void Function() onLockChanged) {
    _timer?.cancel();
    _timer = null;
    if (!_locked) return;
    _locked = false;
    onLockChanged();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _locked = false;
  }
}
