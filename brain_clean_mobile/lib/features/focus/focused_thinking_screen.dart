import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/app_meta_box_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/language_toggle_button.dart';
import '../../core/providers/locale_provider.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/data/xp_ledger_constants.dart';
import '../gamification/domain/xp_source.dart';
import 'data/thinking_log_repository.dart';
import 'domain/focused_thinking_logic.dart';

const focusedThinkingScreenKey = Key('focused_thinking_screen');

enum _ThinkingPhase { selection, active, complete }

/// Deep focused thinking on a single topic for a set duration.
class FocusedThinkingScreen extends ConsumerStatefulWidget {
  const FocusedThinkingScreen({super.key});

  @override
  ConsumerState<FocusedThinkingScreen> createState() =>
      _FocusedThinkingScreenState();
}

class _FocusedThinkingScreenState extends ConsumerState<FocusedThinkingScreen> {
  _ThinkingPhase _phase = _ThinkingPhase.selection;
  String _topic = '';
  int _durationMinutes = 10;
  int _remainingSeconds = 0;
  int _promptIndex = 0;
  int _yesCount = 0;
  int _noCount = 0;
  int _distractionCount = 0;
  int _insightsCount = 0;
  bool _showFocusBanner = false;
  Timer? _countdownTimer;
  Timer? _promptTimer;
  Timer? _focusCheckTimer;
  final _insightController = TextEditingController();

  @override
  void dispose() {
    _cancelTimers();
    _insightController.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _promptTimer?.cancel();
    _focusCheckTimer?.cancel();
  }

  bool get _isArabic => ref.read(localeProvider).languageCode == 'ar';

  double get _focusScore {
    final total = _yesCount + _noCount;
    if (total == 0) return 1;
    return _yesCount / total;
  }

  void _startSession() {
    final topic = _topic.trim();
    if (topic.isEmpty) return;
    _cancelTimers();
    setState(() {
      _phase = _ThinkingPhase.active;
      _remainingSeconds = _durationMinutes * 60;
      _promptIndex = 0;
      _yesCount = 0;
      _noCount = 0;
      _distractionCount = 0;
      _showFocusBanner = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _finishSession();
        return;
      }
      setState(() => _remainingSeconds--);
    });
    _promptTimer = Timer.periodic(
      const Duration(seconds: thinkingPromptIntervalSeconds),
      (_) {
        if (!mounted || _phase != _ThinkingPhase.active) return;
        final prompts = thinkingPromptsForLocale(_isArabic);
        setState(() => _promptIndex = (_promptIndex + 1) % prompts.length);
      },
    );
    _focusCheckTimer = Timer.periodic(
      const Duration(seconds: focusCheckIntervalSeconds),
      (_) {
        if (!mounted || _phase != _ThinkingPhase.active) return;
        setState(() => _showFocusBanner = true);
      },
    );
  }

  void _finishSession() {
    _cancelTimers();
    final bonus = focusedThinkingBcsBonus(_focusScore);
    ref.read(bcScoreProvider.notifier).applyBonus(
          bonus,
          xpSource: XpSource.focusSession,
          xpRefId:
              'focused_thinking_${XpLedgerConstants.utcDayKey(DateTime.now().toUtc())}',
        );
    setState(() => _phase = _ThinkingPhase.complete);
  }

  Future<void> _saveInsight() async {
    final text = _insightController.text.trim();
    if (text.isEmpty) return;
    try {
      final repo = ThinkingLogRepository(ref.read(appMetaBoxProvider));
      await repo.appendEntry(_topic, text);
      setState(() => _insightsCount++);
      _insightController.clear();
    } catch (_) {}
  }

  void _onFocusYes() {
    setState(() {
      _yesCount++;
      _showFocusBanner = false;
    });
  }

  void _onFocusNo() {
    setState(() {
      _noCount++;
      _distractionCount++;
      _showFocusBanner = false;
    });
    final isAr = _isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'عد إلى $_topic — التشتت طبيعي'
              : 'Return to $_topic — distraction is normal',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      key: focusedThinkingScreenKey,
      appBar: AppBar(
        title: Text(loc.focusedThinkingTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: switch (_phase) {
        _ThinkingPhase.selection => _SelectionView(
            loc: loc,
            isAr: isAr,
            topic: _topic,
            durationMinutes: _durationMinutes,
            onTopicChanged: (v) => setState(() => _topic = v),
            onDuration: (m) => setState(() => _durationMinutes = m),
            onStart: _startSession,
          ),
        _ThinkingPhase.active => _ActiveView(
            topic: _topic,
            timeLabel: _formatTime(_remainingSeconds),
            prompt: thinkingPromptsForLocale(isAr)[_promptIndex],
            loc: loc,
            isAr: isAr,
            showBanner: _showFocusBanner,
            onYes: _onFocusYes,
            onNo: _onFocusNo,
          ),
        _ThinkingPhase.complete => _CompleteView(
            topic: _topic,
            focusPercent: (_focusScore * 100).round(),
            distractions: _distractionCount,
            insightsCount: _insightsCount,
            insightController: _insightController,
            loc: loc,
            isAr: isAr,
            onSaveInsight: _saveInsight,
            onDone: () => Navigator.of(context).pop(),
          ),
      },
    );
  }
}

class _SelectionView extends StatelessWidget {
  const _SelectionView({
    required this.loc,
    required this.isAr,
    required this.topic,
    required this.durationMinutes,
    required this.onTopicChanged,
    required this.onDuration,
    required this.onStart,
  });

  final AppLocalizations loc;
  final bool isAr;
  final String topic;
  final int durationMinutes;
  final ValueChanged<String> onTopicChanged;
  final ValueChanged<int> onDuration;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topics = suggestedTopicsForLocale(isAr);
    final customHint = topics.last;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          loc.focusedThinkingSubtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((t) {
            final isCustom = t == customHint;
            final selected = !isCustom && topic == t;
            return ChoiceChip(
              label: Text(t),
              selected: selected,
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelStyle: TextStyle(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              onSelected: (_) {
                if (isCustom) return;
                onTopicChanged(t);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onTopicChanged,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: customHint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          loc.focusedThinkingDurationLabel,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: focusedThinkingDurations.map((m) {
            final selected = durationMinutes == m;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(child: Text('$m')),
                  selected: selected,
                  selectedColor: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  onSelected: (_) => onDuration(m),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: topic.trim().isEmpty ? null : onStart,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loc.focusedThinkingStart),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({
    required this.topic,
    required this.timeLabel,
    required this.prompt,
    required this.loc,
    required this.isAr,
    required this.showBanner,
    required this.onYes,
    required this.onNo,
  });

  final String topic;
  final String timeLabel;
  final String prompt;
  final AppLocalizations loc;
  final bool isAr;
  final bool showBanner;
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  topic,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                timeLabel,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.focusedThinkingGuideTitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showBanner)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAr
                            ? 'هل لا تزال تفكر في $topic؟'
                            : loc.focusedThinkingStillThinking(topic),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onYes,
                      child: Text(isAr ? 'نعم ✓' : loc.focusedThinkingYes),
                    ),
                    TextButton(
                      onPressed: onNo,
                      child: Text(
                        isAr ? 'شردت ✗' : loc.focusedThinkingNo,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({
    required this.topic,
    required this.focusPercent,
    required this.distractions,
    required this.insightsCount,
    required this.insightController,
    required this.loc,
    required this.isAr,
    required this.onSaveInsight,
    required this.onDone,
  });

  final String topic;
  final int focusPercent;
  final int distractions;
  final int insightsCount;
  final TextEditingController insightController;
  final AppLocalizations loc;
  final bool isAr;
  final VoidCallback onSaveInsight;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          topic,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isAr
              ? '$focusPercent% من الوقت كنت مركزاً'
              : loc.focusedThinkingFocusScore(focusPercent),
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          loc.focusedThinkingDistractions(distractions),
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          loc.focusedThinkingInsightsSaved(insightsCount),
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: insightController,
          maxLines: 4,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: loc.focusedThinkingInsightsHint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onSaveInsight,
          child: Text(loc.focusedThinkingSaveInsight),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onDone,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(loc.commonOk),
        ),
      ],
    );
  }
}
