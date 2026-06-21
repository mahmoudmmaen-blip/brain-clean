import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

/// Full-screen breathing friction — duration scales inversely with BHI.
class BreathingFrictionScreen extends StatefulWidget {
  const BreathingFrictionScreen({
    super.key,
    required this.currentBhi,
  });

  final double currentBhi;

  static int frictionDurationSeconds(double currentBhi) =>
      (8 + ((100 - currentBhi) / 10)).ceil();

  @override
  State<BreathingFrictionScreen> createState() =>
      _BreathingFrictionScreenState();
}

enum _BreathPhase { inhale, hold, exhale }

class _BreathingFrictionScreenState extends State<BreathingFrictionScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0D1117);

  late final int _totalSeconds;
  late final AnimationController _breathController;
  Timer? _countdownTimer;

  int _remainingSeconds = 0;
  _BreathPhase _phase = _BreathPhase.inhale;

  @override
  void initState() {
    super.initState();
    _totalSeconds = BreathingFrictionScreen.frictionDurationSeconds(
      widget.currentBhi,
    );
    _remainingSeconds = _totalSeconds;

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 19),
    )..repeat();

    _breathController.addListener(_syncPhaseFromAnimation);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        Navigator.of(context).pop();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _syncPhaseFromAnimation() {
    final t = _breathController.value;
    final next = t < 4 / 19
        ? _BreathPhase.inhale
        : t < 11 / 19
            ? _BreathPhase.hold
            : _BreathPhase.exhale;
    if (next != _phase) {
      setState(() => _phase = next);
    }
  }

  double get _circleScale {
    final t = _breathController.value * 19;
    if (t < 4) {
      return 0.55 + 0.35 * (t / 4);
    }
    if (t < 11) {
      return 0.9;
    }
    final exhaleT = (t - 11) / 8;
    return 0.9 - 0.35 * exhaleT.clamp(0, 1);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breathController.removeListener(_syncPhaseFromAnimation);
    _breathController.dispose();
    super.dispose();
  }

  String _phaseLabel(AppLocalizations loc) => switch (_phase) {
        _BreathPhase.inhale => loc.breathingInhale,
        _BreathPhase.hold => loc.breathingHold,
        _BreathPhase.exhale => loc.breathingExhale,
      };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, _) {
                final size = 200 * _circleScale;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.25),
                    border: Border.all(
                      color: const Color(0xFF1D9E75),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D9E75).withValues(alpha: 0.35),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              _phaseLabel(loc),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: const Color(0xFF30363D),
                      color: const Color(0xFF1D9E75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.breathingCountdownSeconds(_remainingSeconds),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
