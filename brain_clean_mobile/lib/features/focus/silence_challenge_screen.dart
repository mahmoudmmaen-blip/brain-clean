import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../diagnostic/presentation/bc_score_provider.dart';

const silenceCountdownKey = Key('silence_countdown');
const silenceLevelLabelKey = Key('silence_level_label');

/// Full-screen silence challenge — no touch or backgrounding until timer ends.
class SilenceChallengeScreen extends ConsumerStatefulWidget {
  const SilenceChallengeScreen({
    super.key,
    required this.streakDays,
  });

  final int streakDays;

  static int computeLevel(int streakDays) =>
      ((streakDays / 7) + 1).ceil();

  static int targetMinutesForLevel(int level) =>
      10 + ((level - 1) * 2);

  @override
  ConsumerState<SilenceChallengeScreen> createState() =>
      _SilenceChallengeScreenState();
}

class _SilenceChallengeScreenState extends ConsumerState<SilenceChallengeScreen>
    with WidgetsBindingObserver {
  static const _bg = Color(0xFF0D1117);

  late final int _level;
  late final int _targetMinutes;
  late final int _totalSeconds;

  StreamSubscription<int>? _ticker;
  int _remainingSeconds = 0;
  bool _failed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _level = SilenceChallengeScreen.computeLevel(widget.streakDays);
    _targetMinutes = SilenceChallengeScreen.targetMinutesForLevel(_level);
    _totalSeconds = _targetMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Stream.periodic(const Duration(seconds: 1), (t) => t + 1).listen(
      (_) {
        if (!mounted || _failed || _completed) return;
        if (_remainingSeconds <= 1) {
          _onSuccess();
          return;
        }
        setState(() => _remainingSeconds--);
      },
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_failed && !_completed) {
      _onFail();
    }
  }

  void _onFail() {
    if (_failed || _completed) return;
    _failed = true;
    _stopTicker();
    _showFailDialog();
  }

  Future<void> _onSuccess() async {
    if (_failed || _completed) return;
    _completed = true;
    _stopTicker();
    setState(() => _remainingSeconds = 0);
    await _showSuccessDialog();
  }

  Future<void> _showFailDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'فشل التحدي',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: const Text(
          'لمست الشاشة أو خرجت من التطبيق.',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.mounted) context.pop();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'أحسنت! 🎉',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: const Text(
          'اجتزت تحدي الصمت بنجاح.',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(bcScoreProvider.notifier).applyBonus(20);
              Navigator.of(ctx).pop();
              if (context.mounted) context.pop();
            },
            child: const Text('رائع'),
          ),
        ],
      ),
    );
  }

  String get _countdownText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    if (_totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onFail,
      onPanStart: (_) => _onFail(),
      onLongPress: _onFail,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'تحدي الصمت',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لا تلمس الشاشة لمدة $_targetMinutes دقيقة',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B949E),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _SilenceRingPainter(progress: _progress),
                      ),
                      Text(
                        _countdownText,
                        key: silenceCountdownKey,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D9E75),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'المستوى $_level — $_targetMinutes دقيقة مطلوبة',
                  key: silenceLevelLabelKey,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8B949E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SilenceRingPainter extends CustomPainter {
  _SilenceRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const stroke = 4.0;

    final track = Paint()
      ..color = const Color(0xFF30363D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = const Color(0xFF1D9E75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      2 * 3.1415926535 * progress.clamp(0, 1),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_SilenceRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
