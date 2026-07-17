import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../home/presentation/home_streak_provider.dart';
import '../application/daily_program_provider.dart';
import '../domain/daily_program_service.dart';
import '../domain/daily_program_state.dart';
import '../domain/daily_step.dart';
import '../domain/daily_step_status.dart';

const dailyProgramScreenKey = Key('daily_program_screen');

class DailyProgramScreen extends ConsumerWidget {
  const DailyProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final async = ref.watch(dailyProgramProvider);

    return Scaffold(
      key: dailyProgramScreenKey,
      appBar: AppBar(
        title: Text(loc.dailyProgramTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(loc.dailyProgramLoadError)),
        data: (state) => _DailyProgramBody(state: state),
      ),
    );
  }
}

class _DailyProgramBody extends ConsumerStatefulWidget {
  const _DailyProgramBody({required this.state});

  final DailyProgramState state;

  @override
  ConsumerState<_DailyProgramBody> createState() => _DailyProgramBodyState();
}

class _DailyProgramBodyState extends ConsumerState<_DailyProgramBody> {
  final _nextStepKey = GlobalKey();
  String? _rewardChip;
  bool _busy = false;

  String? _secondaryActionLabel(AppLocalizations loc, DailyStep step) {
    return switch (step) {
      DailyStep.mood => loc.dailyProgramOpenEmotionWheel,
      DailyStep.sukoon => loc.dailyProgramOpenCalmExercise,
      DailyStep.journal => loc.dailyProgramOpenWorryJournal,
      _ => null,
    };
  }

  VoidCallback? _secondaryAction(BuildContext context, DailyStep step) {
    return switch (step) {
      DailyStep.mood => () => context.push(AppRoutes.emotionWheel),
      DailyStep.sukoon => () {
          final streakDays = ref.read(homeStreakSnapshotProvider).days;
          context.push(
            AppRoutes.silenceChallenge(streakDays < 0 ? 0 : streakDays),
          );
        },
      DailyStep.journal => () => context.push(AppRoutes.worryJournal),
      _ => null,
    };
  }

  Future<void> _complete(DailyStep step) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(dailyProgramProvider.notifier);
    await notifier.completeStep(step);
    if (!mounted) return;
    setState(() {
      _rewardChip = notifier.lastMicroReward;
      _busy = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _rewardChip = null);
  }

  Future<void> _skip(DailyStep step) async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(dailyProgramProvider.notifier).skipStep(step);
    if (mounted) setState(() => _busy = false);
  }

  void _scrollToNext() {
    final ctx = _nextStepKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final prefs = ref.watch(appPreferencesProvider);
    final state = widget.state;
    final name = prefs.profileDisplayName.trim();
    final morning = DailyProgramService.getMorningMessage(state.date);
    final current = state.currentStep;
    final percent = (state.progressRatio * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                morning,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name.isEmpty
                    ? loc.dailyProgramGreetingGeneric
                    : loc.dailyProgramGreetingNamed(name),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.dailyProgramDayLabel(state.dayNumber),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.isAllDone
                    ? loc.dailyProgramRemainingZero
                    : loc.dailyProgramRemaining(state.remainingCount),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progressRatio,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.dailyProgramProgressPercent(percent),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _nextStepKey,
          child: state.isAllDone
              ? _CompletionCard(
                  loc: loc,
                  onViewReport: () => context.push(AppRoutes.weeklyReport),
                )
              : current == null
                  ? const SizedBox.shrink()
                  : _NextStepCard(
                      entry: current,
                      busy: _busy,
                      rewardChip: _rewardChip,
                      onComplete: () => _complete(current.step),
                      secondaryActionLabel:
                          _secondaryActionLabel(loc, current.step),
                      onSecondaryAction:
                          _secondaryAction(context, current.step),
                      onSkip: current.step == DailyStep.journal
                          ? () => _skip(current.step)
                          : null,
                    ),
        ),
        const SizedBox(height: 20),
        Text(
          loc.dailyProgramAllStepsTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          child: Column(
            children: [
              for (var i = 0; i < state.steps.length; i++) ...[
                if (i > 0) const Divider(height: 16),
                _StepRow(
                  entry: state.steps[i],
                  onTapCurrent: _scrollToNext,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.entry,
    required this.busy,
    required this.rewardChip,
    required this.onComplete,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.onSkip,
  });

  final DailyStepEntry entry;
  final bool busy;
  final String? rewardChip;
  final VoidCallback onComplete;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final step = entry.step;

    return GlassCard(
      child: Column(
        children: [
          Text(
            DailyProgramService.getStepEmoji(step),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            DailyProgramService.getStepTitle(step),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DailyProgramService.getStepSubtitle(step),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          if (rewardChip != null) ...[
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rewardChip!,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: busy ? null : onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    loc.dailyProgramDoneCta,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy ? null : onSecondaryAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: colorScheme.outline),
                foregroundColor: colorScheme.onSurface,
              ),
              child: Text(
                secondaryActionLabel!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (onSkip != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: busy ? null : onSkip,
              child: Text(
                loc.dailyProgramSkip,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.loc,
    required this.onViewReport,
  });

  final AppLocalizations loc;
  final VoidCallback onViewReport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        children: [
          Text(
            loc.dailyProgramCompleteTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onViewReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(loc.dailyProgramViewReport),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.entry,
    required this.onTapCurrent,
  });

  final DailyStepEntry entry;
  final VoidCallback onTapCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final step = entry.step;
    final status = entry.status;

    final statusIcon = switch (status) {
      DailyStepStatus.done => '✅',
      DailyStepStatus.current => '🟡',
      DailyStepStatus.locked => '⬜',
      DailyStepStatus.skipped => '➖',
    };

    final row = Row(
      children: [
        Text(
          DailyProgramService.getStepEmoji(step),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            DailyProgramService.getStepTitle(step),
            style: TextStyle(
              color: status == DailyStepStatus.locked
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: status == DailyStepStatus.current
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          statusIcon,
          style: TextStyle(
            color: status == DailyStepStatus.done
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (status == DailyStepStatus.current) {
      return InkWell(onTap: onTapCurrent, child: row);
    }
    return row;
  }
}
