import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../recovery/domain/recovery_daily_program_sync.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import '../data/worry_repository_provider.dart';
import '../domain/worry_entry.dart';
import 'worry_today_entries_provider.dart';
import 'widgets/worry_journal_widget.dart';
import 'widgets/worry_window_timer_ring.dart';

class WorryWindowScreen extends ConsumerStatefulWidget {
  const WorryWindowScreen({super.key});

  @override
  ConsumerState<WorryWindowScreen> createState() => _WorryWindowScreenState();
}

class _WorryWindowScreenState extends ConsumerState<WorryWindowScreen> {
  static const _uuid = Uuid();

  int _sessionMinutes = 10;
  int _remainingSeconds = 10 * 60;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _saved = false;
  Timer? _timer;
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  int get _totalSeconds => _sessionMinutes * 60;

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _sessionMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _isCompleted = false;
    });
  }

  void _startTimer() {
    if (_isCompleted) return;
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isCompleted = true;
        });
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  Future<bool> _confirmDiscard() async {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          loc.worryDiscardTitle,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          loc.worryDiscardBody,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              loc.commonConfirm,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveAndClose() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      if (mounted) context.pop();
      return;
    }

    final entry = WorryEntry(
      id: _uuid.v4(),
      content: content,
      createdAt: DateTime.now().toUtc(),
      sessionMinutes: _sessionMinutes,
    );
    await ref.read(worryRepositoryProvider).saveEntry(entry);
    await ref
        .read(recoveryProtocolControllerProvider.notifier)
        .applyEngagementAutoMark(RecoveryEngagementAutoMark.mentalSupport);
    ref.invalidate(worryTodayEntriesProvider);
    ref.invalidate(worryHabitDoneTodayProvider);
    setState(() => _saved = true);
    if (mounted) context.pop();
  }

  Future<void> _handleClose() async {
    if (_saved) {
      if (mounted) context.pop();
      return;
    }
    final content = _contentController.text.trim();
    if (content.isNotEmpty) {
      final discard = await _confirmDiscard();
      if (!discard || !mounted) return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleClose();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.worryWindowTitle),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleClose,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(loc.worryDurationTen),
                  selected: _sessionMinutes == 10,
                  onSelected: _isRunning ? null : (_) => _setDuration(10),
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: _sessionMinutes == 10
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
                ChoiceChip(
                  label: Text(loc.worryDurationFifteen),
                  selected: _sessionMinutes == 15,
                  onSelected: _isRunning ? null : (_) => _setDuration(15),
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: _sessionMinutes == 15
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: WorryWindowTimerRing(
                progress: _progress,
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: AppDesignConstants.arabicText(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: colorScheme.onTertiaryContainer,
                ),
                label: Text(
                  loc.worryRuleReminder,
                  style: TextStyle(color: colorScheme.onTertiaryContainer),
                ),
                backgroundColor: colorScheme.tertiaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: loc.worryTimerStart,
                  onPressed: _isRunning || _isCompleted ? null : _startTimer,
                  icon: const Icon(Icons.play_arrow),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: loc.worryTimerPause,
                  onPressed: _isRunning ? _pauseTimer : null,
                  icon: const Icon(Icons.pause),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: loc.worryTimerReset,
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay),
                ),
              ],
            ),
            const SizedBox(height: 20),
            WorryJournalWidget(
              controller: _contentController,
              hintText: loc.worryJournalHint,
            ),
            if (_isCompleted) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Text(
                  loc.worryWindowCompleteMessage,
                  textAlign: TextAlign.center,
                  style: AppDesignConstants.arabicText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: AppDesignConstants.arabicBodyLineHeight,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAndClose,
              child: Text(loc.worrySaveAndClose),
            ),
          ],
        ),
      ),
    );
  }
}
