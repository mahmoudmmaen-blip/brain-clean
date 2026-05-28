import 'dart:async';

import 'package:flutter/widgets.dart';

/// Blocks questionnaire taps while a slide transition animation is active.
///
/// Lock state is driven by per-frame [Animation] ticks (not wall-clock timers alone).
final class SlideLockMechanism {
  SlideLockMechanism({required Duration slideDuration})
      : _slideDuration = slideDuration;

  final Duration _slideDuration;
  Timer? _fallbackTimer;
  Animation<double>? _boundAnimation;
  VoidCallback? _tickListener;
  void Function()? _onLockChanged;
  bool _locked = false;

  /// True while a slide transition is running — all answer taps must be ignored.
  bool get isLocked => _locked;

  /// Binds lock state to [animation] lifecycle: locked on every tick until completed.
  void bindToTransition(
    Animation<double> animation,
    void Function() onLockChanged,
  ) {
    if (identical(_boundAnimation, animation) && _tickListener != null) {
      _onLockChanged = onLockChanged;
      _applyLockFromAnimation(animation);
      return;
    }

    _detachAnimation();
    _onLockChanged = onLockChanged;
    _boundAnimation = animation;

    void tick() => _applyLockFromAnimation(animation);
    _tickListener = tick;
    animation.addListener(tick);
    tick();

    _fallbackTimer = Timer(
      _slideDuration + const Duration(milliseconds: 48),
      () => _setLocked(false),
    );
  }

  void _applyLockFromAnimation(Animation<double> animation) {
    final statusActive = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.reverse;
    final midFrame = animation.value > 0.0 && animation.value < 1.0;
    _setLocked(statusActive || midFrame);
  }

  void _setLocked(bool value) {
    if (_locked == value) return;
    _locked = value;
    _onLockChanged?.call();
  }

  /// Releases the lock and detaches listeners.
  void release(void Function() onLockChanged) {
    _onLockChanged = onLockChanged;
    _detachAnimation();
    _setLocked(false);
  }

  void dispose() {
    _detachAnimation();
    _onLockChanged = null;
    _locked = false;
  }

  void _detachAnimation() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    final animation = _boundAnimation;
    final listener = _tickListener;
    if (animation != null && listener != null) {
      animation.removeListener(listener);
    }
    _boundAnimation = null;
    _tickListener = null;
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
        for (final child in previousChildren)
          _gestureShield(child, block: isLocked),
        if (currentChild != null) _gestureShield(currentChild, block: isLocked),
      ],
    );
  }

  /// [AnimatedSwitcher.transitionBuilder] — syncs lock to [animation] ticks.
  Widget transitionBuilder({
    required Widget child,
    required Animation<double> animation,
    required Widget Function(Widget child, Animation<double> animation) build,
    required void Function() onLockChanged,
  }) {
    bindToTransition(animation, onLockChanged);
    return _gestureShield(
      build(child, animation),
      block: isLocked || animation.status != AnimationStatus.completed,
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
