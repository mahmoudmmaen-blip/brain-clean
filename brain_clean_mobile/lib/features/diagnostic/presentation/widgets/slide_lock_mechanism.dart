import 'dart:async';

import 'package:flutter/widgets.dart';

/// Blocks questionnaire taps for the duration of a question slide transition.
///
/// Used by [BrainRotQuestionPage] to ignore duplicate نعم/لا input while
/// [AnimatedSwitcher] is animating between prompts.
final class SlideLockMechanism {
  SlideLockMechanism({required Duration slideDuration})
      : _slideDuration = slideDuration;

  final Duration _slideDuration;
  Timer? _fallbackTimer;
  AnimationStatusListener? _animationListener;
  Animation<double>? _boundAnimation;
  bool _locked = false;

  /// True while slide animation is active — all answer taps must be ignored.
  bool get isLocked => _locked;

  /// Engages the lock until [slideDuration] elapses, then releases automatically.
  void acquire(void Function() onLockChanged) {
    _cancelListeners();
    _locked = true;
    onLockChanged();
    _fallbackTimer = Timer(_slideDuration, () => release(onLockChanged));
  }

  /// Prefer this when a [AnimationController] drives the card slide — releases on
  /// [AnimationStatus.completed] for frame-accurate unlock (no early/late taps).
  void acquireForAnimation(
    Animation<double> animation,
    void Function() onLockChanged,
  ) {
    _cancelListeners();
    _locked = true;
    _boundAnimation = animation;
    onLockChanged();

    if (animation.status == AnimationStatus.completed) {
      release(onLockChanged);
      return;
    }

    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        release(onLockChanged);
      }
    }

    _animationListener = listener;
    animation.addStatusListener(listener);

    _fallbackTimer = Timer(
      _slideDuration + const Duration(milliseconds: 32),
      () => release(onLockChanged),
    );
  }

  /// Releases the lock immediately (e.g. widget dispose or navigation cancel).
  void release(void Function() onLockChanged) {
    _cancelListeners();
    if (!_locked) return;
    _locked = false;
    onLockChanged();
  }

  void dispose() {
    _cancelListeners();
    _locked = false;
  }

  void _cancelListeners() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    final animation = _boundAnimation;
    final listener = _animationListener;
    if (animation != null && listener != null) {
      animation.removeStatusListener(listener);
    }
    _boundAnimation = null;
    _animationListener = null;
  }

  /// [AnimatedSwitcher.layoutBuilder] — blocks gestures on stacked slide layers.
  Widget layoutBuilder({
    required Widget? currentChild,
    required List<Widget> previousChildren,
    bool forceShield = false,
  }) {
    final shield = forceShield || isLocked;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        for (final child in previousChildren)
          _gestureShield(child, block: shield),
        if (currentChild != null) _gestureShield(currentChild, block: shield),
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
      block: isLocked || transitioning,
    );
  }

  /// Wraps interactive controls (نعم / لا / back) during slide or answer lock.
  Widget shieldInteractions({
    required bool extraLocked,
    required Widget child,
  }) =>
      _gestureShield(child, block: isLocked || extraLocked);

  Widget _gestureShield(Widget child, {required bool block}) {
    if (!block) return child;
    return IgnorePointer(ignoring: true, child: child);
  }
}

/// Liquid slide + fade matching questionnaire navigation direction.
Widget buildBrainRotSlideTransition({
  required Widget child,
  required Animation<double> animation,
  required double horizontalSign,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final offset = Tween<Offset>(
    begin: Offset(horizontalSign * 0.18, 0.02),
    end: Offset.zero,
  ).animate(curved);

  return SlideTransition(
    position: offset,
    child: FadeTransition(
      opacity: Tween<double>(begin: 0.88, end: 1).animate(curved),
      child: child,
    ),
  );
}
