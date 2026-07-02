import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/domain/xp_source.dart';
import 'application/games_scores_provider.dart';
import 'domain/game_scoring.dart';

/// Digit sequence memory — length grows each correct round.
class NumberMemoryGameScreen extends ConsumerStatefulWidget {
  const NumberMemoryGameScreen({super.key});

  @override
  ConsumerState<NumberMemoryGameScreen> createState() =>
      _NumberMemoryGameScreenState();
}

class _NumberMemoryGameScreenState extends ConsumerState<NumberMemoryGameScreen> {
  final _random = Random();
  final _inputController = TextEditingController();

  int _length = 3;
  int _maxDigits = 3;
  int _wrongCount = 0;
  String _sequence = '';
  bool _showSequence = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _newSequence();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _newSequence() {
    _sequence = List.generate(
      _length,
      (_) => _random.nextInt(10).toString(),
    ).join();
    _showSequence = true;
    _inputController.clear();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSequence = false);
    });
  }

  void _submit() {
    if (_showSequence || _finished) return;
    if (_inputController.text.trim() == _sequence) {
      _maxDigits = _length;
      setState(() => _length++);
      _newSequence();
      return;
    }
    setState(() => _wrongCount++);
    if (_wrongCount >= 2) {
      _finish();
      return;
    }
    _newSequence();
  }

  void _finish() {
    final bonus = numberMemoryBcsBonus(_maxDigits);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.game,
          xpRefId: 'number_memory:${DateTime.now().millisecondsSinceEpoch}',
        );
    ref
        .read(gamesBestScoresControllerProvider.notifier)
        .updateNumberMemoryBest(_maxDigits);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.gameNumberMemoryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_finished)
              Text(
                loc.gameNumberMemoryResult(_maxDigits),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (_showSequence)
              Text(
                _sequence,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 40,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              )
            else ...[
              Text(
                loc.gameEnterSequence,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  letterSpacing: 6,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(loc.gameSubmitRound),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
