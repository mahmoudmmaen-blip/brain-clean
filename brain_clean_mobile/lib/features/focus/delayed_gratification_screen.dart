import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../diagnostic/presentation/bc_score_provider.dart';

const delayedGratificationTitleKey = Key('delayed_gratification_title');

/// 20-minute delayed gratification challenge before social media.
class DelayedGratificationScreen extends ConsumerStatefulWidget {
  const DelayedGratificationScreen({super.key});

  static const totalMinutes = 20;
  static const totalSeconds = totalMinutes * 60;

  @override
  ConsumerState<DelayedGratificationScreen> createState() =>
      _DelayedGratificationScreenState();
}

class _DelayedGratificationScreenState
    extends ConsumerState<DelayedGratificationScreen> {
  static const _bg = Color(0xFF0D1117);

  StreamSubscription<int>? _ticker;
  int _remainingSeconds = DelayedGratificationScreen.totalSeconds;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(const Duration(seconds: 1), (t) => t + 1).listen(
      (_) {
        if (!mounted || _completed) return;
        if (_remainingSeconds <= 1) {
          _onSuccess();
          return;
        }
        setState(() => _remainingSeconds--);
      },
    );
  }

  String _quoteForElapsed() {
    final elapsed = DelayedGratificationScreen.totalSeconds - _remainingSeconds;
    final minutes = elapsed ~/ 60;
    if (minutes < 5) return 'الصبر مفتاح الفرج';
    if (minutes < 10) return 'دماغك يشكرك الآن';
    if (minutes < 15) return 'أنت أقوى من خوارزمية';
    return 'لحظات وتنتهي، استمر';
  }

  Future<bool> _confirmAbandon() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'الاستسلام',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: const Text(
          'هل تريد الاستسلام؟ لن تحصل على المكافأة.',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('استسلام'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _onSuccess() async {
    if (_completed) return;
    _completed = true;
    _ticker?.cancel();
    setState(() => _remainingSeconds = 0);

    ref.read(bcScoreProvider.notifier).applyBonus(25);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'انتصرت على نفسك! 🏆',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: const Text(
          '+25 نقطة أضيفت لتركيزك.',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () {
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
    if (DelayedGratificationScreen.totalSeconds <= 0) return 0;
    return _remainingSeconds / DelayedGratificationScreen.totalSeconds;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final abandon = await _confirmAbandon();
        if (abandon && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B949E)),
            onPressed: () async {
              final abandon = await _confirmAbandon();
              if (abandon && context.mounted) context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'تأخير الإشباع',
                  key: delayedGratificationTitleKey,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اصمد 20 دقيقة قبل فتح السوشيال ميديا',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8B949E)),
                ),
                const Spacer(),
                Text(
                  _countdownText,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: const Color(0xFF161B22),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const Spacer(),
                Text(
                  _quoteForElapsed(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFE6EDF3),
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
