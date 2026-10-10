import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../application/session_controller.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../content/exercises_content.dart';
import '../../content/program_content.dart';
import '../../routing/v3_routes.dart';
import 'input_forms.dart';
import 'practice_controls.dart';

class V3SessionPlayerScreen extends ConsumerStatefulWidget {
  const V3SessionPlayerScreen({super.key, required this.day});

  final int day;

  @override
  ConsumerState<V3SessionPlayerScreen> createState() =>
      _V3SessionPlayerScreenState();
}

class _V3SessionPlayerScreenState extends ConsumerState<V3SessionPlayerScreen> {
  bool _inputSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionControllerProvider(widget.day).notifier).ensureStarted();
    });
  }

  int _stepIndex(SessionStep step) => switch (step) {
        SessionStep.lesson => 0,
        SessionStep.practice => 1,
        SessionStep.challenge => 2,
        SessionStep.completion => 2,
      };

  Future<void> _afterChallenge(ProgramDay dayContent) async {
    final ctrl = ref.read(sessionControllerProvider(widget.day).notifier);
    await ctrl.acceptChallenge();

    final needsClarity = dayContent.clarityCheck;
    final state = await ref.read(v3StateRepositoryProvider).load();
    final alreadyToday = state.clarityResults.any((r) {
      final d = r.takenAt;
      final now = DateTime.now();
      return r.programDay == widget.day &&
          d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    });

    if (needsClarity && !alreadyToday) {
      ctrl.setAwaitingClarity(true);
      if (!mounted) return;
      await context.push(
        '${V3Routes.checkPath(mode: 'recheck')}&returnTo=session&day=${widget.day}',
      );
      if (!mounted) return;
    }

    final ok = await ctrl.finishDay(now: DateTime.now());
    if (!ok) {
      // Still show completion UI; day may be incomplete if practice skipped.
      ctrl.showCompletion();
    }
    HapticFeedback.lightImpact();
    setState(() {});

    if (dayContent.graduation) {
      if (mounted) context.go(V3Routes.graduation);
      return;
    }

    final isPro = ref.read(isProUserProvider);
    if (widget.day == 7 && !isPro) {
      final app = await ref.read(v3StateRepositoryProvider).load();
      if (!app.day7PaywallShown) {
        await ref.read(v3StateRepositoryProvider).setDay7PaywallShown(true);
        if (mounted) {
          context.go('${V3Routes.paywall}?source=day7');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final session = ref.watch(sessionControllerProvider(widget.day));
    final contentAsync = ref.watch(v3ContentProvider);

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        final dayContent = bundle.program.dayByNumber(widget.day);
        if (dayContent == null) {
          return Scaffold(body: Center(child: Text(loc.v3SessionMissingDay)));
        }
        final exercise = bundle.exercises.byId(dayContent.practiceId);
        final bonus = dayContent.bonusId == null
            ? null
            : bundle.exercises.byId(dayContent.bonusId!);

        final step = session.step;
        final index = _stepIndex(step);

        return Scaffold(
          backgroundColor: AppDesignConstants.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go(V3Routes.today),
            ),
            title: LinearProgressIndicator(
              value: (index + 1) / 3,
              backgroundColor: AppDesignConstants.darkBorder,
              color: AppDesignConstants.brandGreen,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              child: switch (step) {
                SessionStep.lesson => _LessonStep(
                    day: dayContent,
                    locale: locale,
                    onNext: () => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .completeLesson(),
                    onSkip: () => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .completeLesson(),
                  ),
                SessionStep.practice => _PracticeStep(
                    day: dayContent,
                    exercise: exercise,
                    bonus: bonus,
                    locale: locale,
                    showEasy: session.showEasy,
                    inputSaved: _inputSaved,
                    onToggleEasy: (v) => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .toggleEasy(v),
                    onEasyComplete: () => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .markEasyUsed(),
                    onPracticeComplete: () => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .completePractice(),
                    onSkip: () => ref
                        .read(sessionControllerProvider(widget.day).notifier)
                        .skipPractice(),
                    onInputSaved: () => setState(() => _inputSaved = true),
                  ),
                SessionStep.challenge => _ChallengeStep(
                    text: dayContent.challenge.resolve(locale),
                    onAccept: () => _afterChallenge(dayContent),
                    onSkip: () => _afterChallenge(dayContent),
                  ),
                SessionStep.completion => _CompletionStep(
                    day: widget.day,
                    keyIdea: dayContent.lesson.key.resolve(locale),
                    onBack: () => context.go(V3Routes.today),
                  ),
              },
            ),
          ),
        );
      },
    );
  }
}

class _LessonStep extends StatelessWidget {
  const _LessonStep({
    required this.day,
    required this.locale,
    required this.onNext,
    required this.onSkip,
  });

  final ProgramDay day;
  final String locale;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final paragraphs = day.lesson.body.resolve(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.lesson.title.resolve(locale),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppDesignConstants.darkOnSurface,
                  ),
                ),
                const SizedBox(height: 16),
                for (final p in paragraphs) ...[
                  Text(
                    p,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppDesignConstants.darkOnSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppDesignConstants.brandGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppDesignConstants.brandGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    day.lesson.key.resolve(locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppDesignConstants.darkOnSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        FilledButton(
          onPressed: onNext,
          style: FilledButton.styleFrom(
            backgroundColor: AppDesignConstants.brandGreen,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loc.v3LessonNext),
        ),
        TextButton(onPressed: onSkip, child: Text(loc.v3Skip)),
      ],
    );
  }
}

class _PracticeStep extends StatelessWidget {
  const _PracticeStep({
    required this.day,
    required this.exercise,
    required this.bonus,
    required this.locale,
    required this.showEasy,
    required this.inputSaved,
    required this.onToggleEasy,
    required this.onEasyComplete,
    required this.onPracticeComplete,
    required this.onSkip,
    required this.onInputSaved,
  });

  final ProgramDay day;
  final ExerciseContent? exercise;
  final ExerciseContent? bonus;
  final String locale;
  final bool showEasy;
  final bool inputSaved;
  final ValueChanged<bool> onToggleEasy;
  final VoidCallback onEasyComplete;
  final VoidCallback onPracticeComplete;
  final VoidCallback onSkip;
  final VoidCallback onInputSaved;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (exercise == null) {
      return Center(child: Text(loc.v3SessionMissingExercise));
    }
    final ex = exercise!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.title.resolve(locale),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ex.why.resolve(locale),
                  style: const TextStyle(
                    color: AppDesignConstants.darkOnSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.v3EasyToggle),
                  value: showEasy,
                  onChanged: onToggleEasy,
                ),
                if (showEasy) ...[
                  Text(
                    ex.easy.resolve(locale),
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onEasyComplete,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesignConstants.brandGreen,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(loc.v3PracticeDone),
                  ),
                ] else ...[
                  if (ex.input != null && !inputSaved)
                    PracticeInputForm(
                      inputKey: ex.input!,
                      onSaved: onInputSaved,
                    )
                  else
                    PracticeModeControl(
                      exercise: ex,
                      onComplete: onPracticeComplete,
                    ),
                ],
                if (bonus != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppDesignConstants.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${loc.v3BonusExercise}\n${bonus!.title.resolve(locale)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        TextButton(onPressed: onSkip, child: Text(loc.v3Skip)),
      ],
    );
  }
}

class _ChallengeStep extends StatelessWidget {
  const _ChallengeStep({
    required this.text,
    required this.onAccept,
    required this.onSkip,
  });

  final String text;
  final VoidCallback onAccept;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1.4),
            ),
          ),
        ),
        FilledButton(
          onPressed: onAccept,
          style: FilledButton.styleFrom(
            backgroundColor: AppDesignConstants.brandGreen,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loc.v3ChallengeAccept),
        ),
        TextButton(onPressed: onSkip, child: Text(loc.v3Skip)),
      ],
    );
  }
}

class _CompletionStep extends StatefulWidget {
  const _CompletionStep({
    required this.day,
    required this.keyIdea,
    required this.onBack,
  });

  final int day;
  final String keyIdea;
  final VoidCallback onBack;

  @override
  State<_CompletionStep> createState() => _CompletionStepState();
}

class _CompletionStepState extends State<_CompletionStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        const Spacer(),
        ScaleTransition(
          scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 88,
            color: AppDesignConstants.brandGreen,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.v3SessionComplete(widget.day),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.keyIdea,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppDesignConstants.darkOnSurfaceMuted,
            height: 1.4,
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: widget.onBack,
          style: FilledButton.styleFrom(
            backgroundColor: AppDesignConstants.brandGreen,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loc.v3BackToToday),
        ),
      ],
    );
  }
}
