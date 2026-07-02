import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/data/xp_ledger_constants.dart';
import '../gamification/domain/xp_source.dart';

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

  String _quoteForElapsed(AppLocalizations loc) {
    final elapsed = DelayedGratificationScreen.totalSeconds - _remainingSeconds;
    final minutes = elapsed ~/ 60;
    if (minutes < 5) return loc.delayedGratQuoteUnder5;
    if (minutes < 10) return loc.delayedGratQuoteUnder10;
    if (minutes < 15) return loc.delayedGratQuoteUnder15;
    return loc.delayedGratQuoteDefault;
  }

  Future<bool> _confirmAbandon() async {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          loc.delayedGratGiveUpTitle,
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          loc.delayedGratGiveUpBody,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              loc.commonCancel,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.delayedGratGiveUpButton),
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

    ref.read(bcScoreProvider.notifier).applyBonus(
          25,
          xpSource: XpSource.focusSession,
          xpRefId:
              'delayed_grat_${XpLedgerConstants.utcDayKey(DateTime.now().toUtc())}',
        );

    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          loc.delayedGratVictoryTitle,
          style: TextStyle(color: cs.onSurface),
        ),
        content: Text(
          loc.delayedGratVictoryBody,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.mounted) context.pop();
            },
            child: Text(loc.commonGreat),
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
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final abandon = await _confirmAbandon();
        if (abandon && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurfaceVariant),
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
                Text(
                  loc.delayedGratTitle,
                  key: delayedGratificationTitleKey,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.delayedGratSubtitle,
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                Text(
                  _countdownText,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: cs.surface,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  _quoteForElapsed(loc),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurface,
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
