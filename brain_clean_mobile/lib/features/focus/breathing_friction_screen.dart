import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Full-screen breathing friction — duration scales inversely with BHI.
class BreathingFrictionScreen extends StatefulWidget {
  const BreathingFrictionScreen({
    super.key,
    required this.currentBhi,
  });

  final int currentBhi;

  static int frictionDurationSeconds(int currentBhi) =>
      (8 + ((100 - currentBhi) / 10)).round();

  @override
  State<BreathingFrictionScreen> createState() =>
      _BreathingFrictionScreenState();
}

enum _BreathPhase { inhale, hold, exhale }

class _BreathingFrictionScreenState extends State<BreathingFrictionScreen> {
  static const _bg = Color(0xFF0D1117);

  late final int _totalSeconds;
  StreamSubscription<int>? _ticker;
  Timer? _phaseTimer;
  int _elapsedSeconds = 0;

  _BreathPhase _phase = _BreathPhase.inhale;
  double _circleSize = 80;
  Duration _sizeAnimDuration = const Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _totalSeconds = BreathingFrictionScreen.frictionDurationSeconds(
      widget.currentBhi,
    );
    _beginInhale();
    _ticker = Stream.periodic(const Duration(seconds: 1), (tick) => tick + 1)
        .listen((tick) {
      if (!mounted) return;
      if (tick >= _totalSeconds) {
        _finishSession();
        return;
      }
      setState(() => _elapsedSeconds = tick);
    });
  }

  void _finishSession() {
    _ticker?.cancel();
    _phaseTimer?.cancel();
    if (mounted) context.pop();
  }

  void _beginInhale() {
    setState(() {
      _phase = _BreathPhase.inhale;
      _sizeAnimDuration = const Duration(seconds: 4);
      _circleSize = 180;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 4), _beginHold);
  }

  void _beginHold() {
    if (!mounted) return;
    setState(() {
      _phase = _BreathPhase.hold;
      _circleSize = 180;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 7), _beginExhale);
  }

  void _beginExhale() {
    if (!mounted) return;
    setState(() {
      _phase = _BreathPhase.exhale;
      _sizeAnimDuration = const Duration(seconds: 8);
      _circleSize = 80;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _elapsedSeconds < _totalSeconds) _beginInhale();
    });
  }

  String get _phaseLabel => switch (_phase) {
        _BreathPhase.inhale => 'استنشق ببطء...',
        _BreathPhase.hold => 'احتبس...',
        _BreathPhase.exhale => 'أخرج الهواء...',
      };

  double get _countdownProgress {
    if (_totalSeconds <= 0) return 0;
    return (1.0 - (_elapsedSeconds / _totalSeconds)).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _phaseLabel,
                key: ValueKey(_phaseLabel),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedContainer(
              duration: _sizeAnimDuration,
              curve: Curves.easeInOut,
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF0F7A5A)],
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 24,
                    color: Color(0x661D9E75),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _countdownProgress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF161B22),
                  color: const Color(0xFF1D9E75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
