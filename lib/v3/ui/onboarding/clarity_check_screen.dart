import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/clarity_check_session_provider.dart';
import '../../application/clarity_scoring_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/clarity_check_content.dart';
import '../../content/content_repository.dart';
import '../../domain/clarity_scoring.dart';
import '../../domain/program_engine.dart';
import '../../routing/v3_routes.dart';
import 'onboarding_keys.dart';
import 'widgets/clarity_progress_dots.dart';

class V3ClarityCheckScreen extends ConsumerStatefulWidget {
  const V3ClarityCheckScreen({super.key, required this.mode});

  final ClarityCheckMode mode;

  @override
  ConsumerState<V3ClarityCheckScreen> createState() =>
      _V3ClarityCheckScreenState();
}

class _V3ClarityCheckScreenState extends ConsumerState<V3ClarityCheckScreen> {
  bool _showRecheckSummary = false;
  ClarityScoreOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = await ref.read(v3AppStateProvider.future);
      final previous = state.clarityResults.isEmpty
          ? null
          : state.clarityResults.last.score;
      ref.read(clarityCheckSessionProvider.notifier).reset(
            mode: widget.mode,
            previousScore: previous,
          );
    });
  }

  int get _questionCount {
    final content = ref.read(v3ContentProvider).valueOrNull;
    return content?.clarityCheck.questions.length ?? 8;
  }

  Future<void> _finishCheck() async {
    final bundle = await ref.read(v3ContentProvider.future);
    final session = ref.read(clarityCheckSessionProvider);
    final locale = ref.read(localeProvider).languageCode;
    final runner = ref.read(clarityScoringProvider);
    final outcome = runner.compute(
      content: bundle.clarityCheck,
      answers: session.answers,
      hoursEstimate: session.hoursEstimate ?? 3,
    );
    setState(() {
      _outcome = outcome;
      _showRecheckSummary = widget.mode == ClarityCheckMode.recheck;
    });

    final progress =
        ref.read(v3AppStateProvider).valueOrNull?.dayProgress ?? const [];
    final programDay = widget.mode == ClarityCheckMode.baseline
        ? 1
        : ProgramEngine.currentDay(progress);

    final result = ClarityScoring.toResult(
      outcome: outcome,
      programDay: programDay.clamp(1, 30),
      takenAt: DateTime.now(),
      hoursEstimate: session.hoursEstimate ?? 3,
      answers: session.answers,
    );
    await ref.read(v3StateRepositoryProvider).appendClarityResult(result);
    ref.invalidate(v3AppStateProvider);

    if (widget.mode == ClarityCheckMode.baseline) {
      if (mounted) context.go(V3Routes.setup);
    }
  }

  void _onOptionTap(VoidCallback advance) {
    HapticFeedback.lightImpact();
    advance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final contentAsync = ref.watch(v3ContentProvider);
    final session = ref.watch(clarityCheckSessionProvider);

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        if (_showRecheckSummary && _outcome != null) {
          final prev = session.previousScore;
          final delta = prev != null ? _outcome!.score - prev : null;
          return Scaffold(
            backgroundColor: AppDesignConstants.darkBackground,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.v3ClarityScoreLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppDesignConstants.darkOnSurfaceMuted,
                      ),
                    ),
                    Text(
                      '${_outcome!.score}',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppDesignConstants.brandGreen,
                      ),
                    ),
                    if (delta != null)
                      Text(
                        loc.v3RecheckComparison(delta),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppDesignConstants.darkOnSurface,
                        ),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => context.go(V3Routes.today),
                      child: Text(loc.v3CheckDone),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final clarity = bundle.clarityCheck;
        final totalSteps = 1 + 1 + clarity.questions.length;
        final step = session.step.clamp(0, totalSteps - 1);

        return Scaffold(
          backgroundColor: AppDesignConstants.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      ref
                          .read(clarityCheckSessionProvider.notifier)
                          .setStep(step - 1);
                      setState(() {});
                    },
                  )
                : null,
            title: ClarityProgressDots(
              total: totalSteps,
              current: step,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              child: _buildStep(
                context,
                loc: loc,
                locale: locale,
                clarity: clarity,
                step: step,
                session: session,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required AppLocalizations loc,
    required String locale,
    required ClarityCheckContent clarity,
    required int step,
    required ClarityCheckSessionState session,
  }) {
    if (step == 0) {
      return _IntroStep(
        text: clarity.intro.resolve(locale),
        onContinue: () {
          ref.read(clarityCheckSessionProvider.notifier).setStep(1);
          setState(() {});
        },
      );
    }
    if (step == 1) {
      final q = clarity.screenTimeQuestion;
      return _OptionsStep(
        title: q.text.resolve(locale),
        options: q.options
            .map(
              (o) => _Option(
                label: o.label.resolve(locale),
                onTap: () => _onOptionTap(() {
                  ref
                      .read(clarityCheckSessionProvider.notifier)
                      .recordHours(o.value);
                }),
              ),
            )
            .toList(),
      );
    }

    final qIndex = step - 2;
    final question = clarity.questions[qIndex];
    final scale = clarity.scale;
    final isLast = qIndex == clarity.questions.length - 1;

    return _OptionsStep(
      title: question.text.resolve(locale),
      options: scale
          .map(
            (o) => _Option(
              label: o.label.resolve(locale),
              onTap: () => _onOptionTap(() {
                ref.read(clarityCheckSessionProvider.notifier).recordAnswer(
                      question.id,
                      o.value,
                    );
                if (isLast) {
                  _finishCheck();
                }
              }),
            ),
          )
          .toList(),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.text, required this.onContinue});

  final String text;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: AppDesignConstants.darkOnSurface,
              ),
            ),
          ),
        ),
        FilledButton(
          key: V3OnboardingKeys.checkContinue,
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: AppDesignConstants.brandGreen,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(loc.v3CheckContinue),
        ),
      ],
    );
  }
}

class _Option {
  const _Option({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

class _OptionsStep extends StatelessWidget {
  const _OptionsStep({required this.title, required this.options});

  final String title;
  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppDesignConstants.darkOnSurface,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final opt = options[index];
              return Material(
                color: AppDesignConstants.darkSurface,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  key: index == 0 ? V3OnboardingKeys.checkOption : null,
                  borderRadius: BorderRadius.circular(20),
                  onTap: opt.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Text(
                      opt.label,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppDesignConstants.darkOnSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
