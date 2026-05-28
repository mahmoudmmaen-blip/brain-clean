import 'dart:async';

import 'package:flutter/material.dart';

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

  /// [AnimatedSwitcher.layoutBuilder] — blocks gestures on stacked slide layers.
  Widget layoutBuilder({
    required Widget? currentChild,
    required List<Widget> previousChildren,
  }) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        for (final child in previousChildren) _gestureShield(child),
        if (currentChild != null) _gestureShield(currentChild),
      ],
    );
  }

  /// [AnimatedSwitcher.transitionBuilder] — blocks gestures on the transitioning card.
  Widget transitionBuilder({
    required Widget child,
    required Animation<double> animation,
    required Widget Function(Widget child, Animation<double> animation) build,
  }) {
    final transitioning = animation.status != AnimationStatus.completed;
    return _gestureShield(
      build(child, animation),
      forceBlock: isLocked || transitioning,
    );
  }

  /// Wraps interactive controls (نعم / لا / back) during slide or answer lock.
  Widget shieldInteractions({
    required bool extraLocked,
    required Widget child,
  }) =>
      _gestureShield(child, forceBlock: isLocked || extraLocked);

  Widget _gestureShield(Widget child, {bool? forceBlock}) {
    final block = forceBlock ?? isLocked;
    if (!block) return child;
    return IgnorePointer(
      ignoring: true,
      child: AbsorbPointer(
        absorbing: true,
        child: child,
      ),
    );
  }
}
