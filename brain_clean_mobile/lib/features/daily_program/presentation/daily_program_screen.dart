import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../emotions/application/emotion_provider.dart';
import '../../emotions/data/emotion_log_repository.dart';
import '../../focus/application/silence_challenge_daily_program_gate.dart';
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
        // Keep prior data visible on reload — avoids spinner flash / shake.
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
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
  String? _rewardChip;
  bool _busy = false;

  String? _secondaryActionLabel(AppLocalizations loc, DailyStep step) {
    return switch (step) {
      DailyStep.mood => loc.dailyProgramOpenEmotionWheel,
      DailyStep.sukoon => loc.dailyProgramOpenCalmExercise,
      DailyStep.focusTask => loc.dailyProgramOpenSingleTask,
      DailyStep.journal => loc.dailyProgramOpenWorryJournal,
      _ => null,
    };
  }

  /// Route hooks from Daily Program — arm gates so a successful action
  /// inside the destination can complete the related step. Opening alone
  /// never completes. Primary Done remains the fallback.
  VoidCallback? _secondaryAction(BuildContext context, DailyStep step) {
    return switch (step) {
      DailyStep.mood => () {
          // Same gate path as primary "Choose your mood".
          ref.read(emotionWheelDailyProgramGateProvider.notifier).arm();
          context.push(AppRoutes.emotionWheel);
        },
      DailyStep.sukoon => () {
          // streakDays is a safe default already used by Home / Silence Challenge.
          final streakDays = ref.read(homeStreakSnapshotProvider).days;
          ref.read(silenceChallengeDailyProgramGateProvider.notifier).arm();
          context.push(AppRoutes.silenceChallenge(streakDays));
        },
      DailyStep.focusTask => () => context.go(AppRoutes.singleTask),
      // TODO: arm journal gate after save when one exists; manual Done for now.
      DailyStep.journal => () => context.push(AppRoutes.worryJournal),
      _ => null,
    };
  }

  Future<void> _complete(DailyStep step) async {
    if (step == DailyStep.mood) {
      await _openMoodWheelAndCompleteIfLogged();
      return;
    }
    if (step == DailyStep.water) {
      await _showWaterSheet(context);
      return;
    }
    if (step == DailyStep.movement) {
      await _showMovementSheet(context);
      return;
    }
    if (step == DailyStep.dayEnd) {
      await context.push(AppRoutes.dayEnd);
      return;
    }
    await _completeStepWithFeedback(step);
  }

  Future<void> _completeStepWithFeedback(DailyStep step) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(dailyProgramProvider.notifier);
    await notifier.completeStep(step);
    if (!mounted) return;
    final reward = notifier.lastMicroReward;
    setState(() {
      _rewardChip = reward;
      _busy = false;
    });
    if (reward == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _rewardChip = null);
  }

  Future<void> _showWaterSheet(BuildContext context) async {
    if (_busy) return;
    final loc = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ConfirmationSheetShell(
          title: loc.dailyProgramWaterSheetTitle,
          subtitle: loc.dailyProgramWaterSheetSubtitle,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _completeStepWithFeedback(DailyStep.water);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(sheetContext).colorScheme.primary,
                foregroundColor: Theme.of(sheetContext).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(loc.dailyProgramWaterConfirm),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(
                loc.dailyProgramWaterLater,
                style: TextStyle(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMovementSheet(BuildContext context) async {
    if (_busy) return;
    final loc = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return _ConfirmationSheetShell(
          title: loc.dailyProgramMovementSheetTitle,
          subtitle: loc.dailyProgramMovementSheetSubtitle,
          children: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _completeStepWithFeedback(DailyStep.movement);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(loc.dailyProgramMovementConfirm),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: colorScheme.outline),
                foregroundColor: colorScheme.onSurface,
              ),
              child: Text(loc.dailyProgramMovementDoNow),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await _completeStepWithFeedback(DailyStep.movement);
              },
              child: Text(
                loc.dailyProgramMovementSkipToday,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Opens Emotion Wheel; completes mood only if a new today log exists on return.
  Future<void> _openMoodWheelAndCompleteIfLogged() async {
    if (_busy) return;
    setState(() => _busy = true);

    DateTime? baseline;
    try {
      baseline =
          ref.read(emotionLogRepositoryProvider).latestTodayTimestamp();
    } catch (_) {
      // Hive may be unavailable in edge cases — still open the wheel.
    }

    // Keep existing EmotionWheel gate path for confirmImpact auto-complete.
    ref.read(emotionWheelDailyProgramGateProvider.notifier).arm();

    await context.push(AppRoutes.emotionWheel);
    if (!mounted) return;

    final program = ref.read(dailyProgramProvider).valueOrNull;
    final current = program?.currentStep;
    final stillOnMood = current != null &&
        current.step == DailyStep.mood &&
        current.status == DailyStepStatus.current;

    if (stillOnMood) {
      var loggedSinceOpen = false;
      try {
        loggedSinceOpen = ref
            .read(emotionLogRepositoryProvider)
            .hasLoggedToday(after: baseline);
      } catch (_) {}

      if (loggedSinceOpen) {
        final notifier = ref.read(dailyProgramProvider.notifier);
        await notifier.completeStep(DailyStep.mood);
        if (!mounted) return;
        final reward = notifier.lastMicroReward;
        setState(() {
          _rewardChip = reward;
          _busy = false;
        });
        if (reward != null) {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          if (mounted) setState(() => _rewardChip = null);
        }
        return;
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _skip(DailyStep step) async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(dailyProgramProvider.notifier).skipStep(step);
    if (mounted) setState(() => _busy = false);
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

    // Header + current step stay outside the steps ListView so completing
    // a step does not jump/scroll the "كل خطوات اليوم" list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _ProgramHeader(
            morning: morning,
            greeting: name.isEmpty
                ? loc.dailyProgramGreetingGeneric
                : loc.dailyProgramGreetingNamed(name),
            dayLabel: loc.dailyProgramDayLabel(state.dayNumber),
            remainingLabel: state.isAllDone
                ? loc.dailyProgramRemainingZero
                : loc.dailyProgramRemaining(state.remainingCount),
            progress: state.progressRatio,
            percentLabel: loc.dailyProgramProgressPercent(percent),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: state.isAllDone
              ? _CompletionCard(
                  loc: loc,
                  onViewReport: () => context.push(AppRoutes.weeklyReport),
                )
              : current == null
                  ? const SizedBox.shrink()
                  : _NextStepCard(
                      key: ValueKey(current.step),
                      entry: current,
                      busy: _busy,
                      rewardChip: _rewardChip,
                      doneLabel: current.step == DailyStep.mood
                          ? loc.dailyProgramChooseMood
                          : loc.dailyProgramDoneCta,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            loc.dailyProgramAllStepsTitle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              GlassCard(
                child: Column(
                  children: [
                    for (var i = 0; i < state.steps.length; i++) ...[
                      if (i > 0) const Divider(height: 16),
                      _StepRow(
                        key: ValueKey(state.steps[i].step),
                        entry: state.steps[i],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgramHeader extends StatelessWidget {
  const _ProgramHeader({
    required this.morning,
    required this.greeting,
    required this.dayLabel,
    required this.remainingLabel,
    required this.progress,
    required this.percentLabel,
  });

  final String morning;
  final String greeting;
  final String dayLabel;
  final String remainingLabel;
  final double progress;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
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
            greeting,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            remainingLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Instant bar — LinearProgressIndicator's implicit animation
          // felt like screen shake when progress + card swapped together.
          _InstantProgressBar(value: progress),
          const SizedBox(height: 6),
          Text(
            percentLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstantProgressBar extends StatelessWidget {
  const _InstantProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 10,
        child: ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: clamped,
              child: ColoredBox(color: colorScheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    super.key,
    required this.entry,
    required this.busy,
    required this.rewardChip,
    required this.doneLabel,
    required this.onComplete,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.onSkip,
  });

  final DailyStepEntry entry;
  final bool busy;
  final String? rewardChip;
  final String doneLabel;
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
            DailyProgramService.getStepTitle(
              step,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DailyProgramService.getStepSubtitle(
              step,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          if (rewardChip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    doneLabel,
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
    super.key,
    required this.entry,
  });

  final DailyStepEntry entry;

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

    return Row(
      children: [
        Text(
          DailyProgramService.getStepEmoji(step),
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            DailyProgramService.getStepTitle(
              step,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
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
  }
}

class _ConfirmationSheetShell extends StatelessWidget {
  const _ConfirmationSheetShell({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.14)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
