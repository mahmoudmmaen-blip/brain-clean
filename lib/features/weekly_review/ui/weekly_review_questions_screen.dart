import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/weekly_review_controller.dart';
import '../data/weekly_review_controller_provider.dart';
import '../domain/weekly_review_enums.dart';
import '../domain/weekly_review_question.dart';
import '../domain/weekly_review_response.dart';

/// WRV-01 — structured one-question-at-a-time Weekly Review.
class WeeklyReviewQuestionsScreen extends ConsumerStatefulWidget {
  const WeeklyReviewQuestionsScreen({super.key});

  @override
  ConsumerState<WeeklyReviewQuestionsScreen> createState() =>
      _WeeklyReviewQuestionsScreenState();
}

class _WeeklyReviewQuestionsScreenState
    extends ConsumerState<WeeklyReviewQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weeklyReviewControllerProvider).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = ref.watch(weeklyReviewControllerProvider);

    if (c.phase == WeeklyReviewUiPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(AppRoutes.v2WeeklyReviewSummary);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(loc.v2WeeklyReviewTitle),
        ),
        actions: [
          TextButton(
            onPressed: () {
              c.exitPreservingDraft();
              context.go(AppRoutes.v2Today);
            },
            child: Text(loc.v2WeeklyReviewExit),
          ),
        ],
      ),
      body: SafeArea(
        child: WeeklyReviewQuestionsBody(controller: c),
      ),
    );
  }
}

@visibleForTesting
class WeeklyReviewQuestionsBody extends StatelessWidget {
  const WeeklyReviewQuestionsBody({super.key, required this.controller});

  final WeeklyReviewController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;

    if (c.phase == WeeklyReviewUiPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2WeeklyReviewLoading,
          child: Text(loc.v2WeeklyReviewLoading),
        ),
      );
    }

    if (c.phase == WeeklyReviewUiPhase.saveFailed) {
      return _MessagePad(
        title: loc.v2WeeklyReviewSaveFailed,
        cta: loc.v2WeeklyReviewRetry,
        onCta: () => c.bootstrap(),
      );
    }

    if (c.phase == WeeklyReviewUiPhase.unsupported) {
      return _MessagePad(
        title: loc.v2WeeklyReviewUnsupported,
        cta: loc.v2WeeklyReviewBackToday,
        onCta: () => context.go(AppRoutes.v2Today),
      );
    }

    if (c.phase == WeeklyReviewUiPhase.notEligible) {
      return _MessagePad(
        title: _notReadyTitle(loc, c.notEligibleReason),
        body: _notReadyBody(loc, c.notEligibleReason),
        cta: loc.v2WeeklyReviewBackToday,
        onCta: () => context.go(AppRoutes.v2Today),
      );
    }

    final period = c.period;
    final question = c.currentQuestion;
    final record = c.record;
    if (period == null || question == null || record == null) {
      return _MessagePad(
        title: loc.v2WeeklyReviewNotReadyGeneric,
        cta: loc.v2WeeklyReviewBackToday,
        onCta: () => context.go(AppRoutes.v2Today),
      );
    }

    final step = (record.questionIndex + 1).toString();
    final total = c.questionCount.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    loc.v2WeeklyReviewPeriodLabel(
                      period.startDayKey,
                      period.endDayKey,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: loc.v2WeeklyReviewProgressSemantics(step, total),
                  child: Text(loc.v2WeeklyReviewProgress(step, total)),
                ),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    _questionPrompt(loc, question.id),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (question.required) ...[
                  const SizedBox(height: 4),
                  Text(
                    loc.v2WeeklyReviewRequired,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (question.type == WeeklyReviewQuestionType.multiSelect) ...[
                  const SizedBox(height: 4),
                  Text(
                    loc.v2WeeklyReviewMultiSelectHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                _AnswerControl(
                  question: question,
                  existing: record.responsesById[question.id],
                  onAnswer: (response) async {
                    final ok = await c.answerCurrent(response);
                    if (!ok && context.mounted) {
                      // stay; validation shown
                    }
                  },
                ),
                if (c.validationError != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      loc.v2WeeklyReviewValidationHint,
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: record.questionIndex == 0
                              ? null
                              : () => c.goBack(),
                          child: Text(loc.v2WeeklyReviewBack),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () async {
                            if (record.questionIndex >= c.questionCount - 1) {
                              if (c.canComplete) {
                                final ok = await c.complete();
                                if (ok && context.mounted) {
                                  context.go(AppRoutes.v2WeeklyReviewSummary);
                                }
                              } else {
                                // force validation
                                c.goForward();
                              }
                            } else {
                              await c.goForward();
                            }
                          },
                          child: Text(
                            record.questionIndex >= c.questionCount - 1
                                ? loc.v2WeeklyReviewComplete
                                : loc.v2WeeklyReviewContinue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _notReadyTitle(
    AppLocalizations loc,
    WeeklyReviewNotEligibleReason? reason,
  ) {
    switch (reason) {
      case WeeklyReviewNotEligibleReason.zeroCompletedSessions:
        return loc.v2WeeklyReviewNotReadyZeroTitle;
      case WeeklyReviewNotEligibleReason.currentWeek:
        return loc.v2WeeklyReviewNotReadyCurrentTitle;
      case WeeklyReviewNotEligibleReason.missingPlan:
      case WeeklyReviewNotEligibleReason.missingProfile:
      case WeeklyReviewNotEligibleReason.missingProgressSnapshot:
        return loc.v2WeeklyReviewNotReadyMissingTitle;
      default:
        return loc.v2WeeklyReviewNotReadyGeneric;
    }
  }

  static String _notReadyBody(
    AppLocalizations loc,
    WeeklyReviewNotEligibleReason? reason,
  ) {
    switch (reason) {
      case WeeklyReviewNotEligibleReason.zeroCompletedSessions:
        return loc.v2WeeklyReviewNotReadyZeroBody;
      case WeeklyReviewNotEligibleReason.currentWeek:
        return loc.v2WeeklyReviewNotReadyCurrentBody;
      case WeeklyReviewNotEligibleReason.missingPlan:
      case WeeklyReviewNotEligibleReason.missingProfile:
      case WeeklyReviewNotEligibleReason.missingProgressSnapshot:
        return loc.v2WeeklyReviewNotReadyMissingBody;
      default:
        return loc.v2WeeklyReviewNotReadyGenericBody;
    }
  }

  static String _questionPrompt(AppLocalizations loc, String id) {
    switch (id) {
      case WeeklyReviewQuestionCatalog.manageability:
        return loc.v2WeeklyReviewQManageability;
      case WeeklyReviewQuestionCatalog.pauseFocus:
        return loc.v2WeeklyReviewQPauseFocus;
      case WeeklyReviewQuestionCatalog.obstacle:
        return loc.v2WeeklyReviewQObstacle;
      case WeeklyReviewQuestionCatalog.support:
        return loc.v2WeeklyReviewQSupport;
      case WeeklyReviewQuestionCatalog.accessibilityUsed:
        return loc.v2WeeklyReviewQAccessibility;
      default:
        return id;
    }
  }
}

class _AnswerControl extends StatelessWidget {
  const _AnswerControl({
    required this.question,
    required this.existing,
    required this.onAnswer,
  });

  final WeeklyReviewQuestion question;
  final WeeklyReviewResponse? existing;
  final Future<void> Function(WeeklyReviewResponse) onAnswer;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now().toUtc();

    switch (question.type) {
      case WeeklyReviewQuestionType.singleChoice:
        return Column(
          children: [
            for (final value in question.allowedValues)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(_optionLabel(loc, value)),
                    ),
                    selected: existing?.singleChoice == value,
                    onSelected: (_) => onAnswer(
                      WeeklyReviewResponse(
                        questionId: question.id,
                        answeredAt: now,
                        singleChoice: value,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      case WeeklyReviewQuestionType.boundedScale:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = question.scaleMin!; i <= question.scaleMax!; i++)
              SizedBox(
                height: 48,
                width: 48,
                child: ChoiceChip(
                  label: Text('$i'),
                  selected: existing?.scaleValue == i,
                  onSelected: (_) => onAnswer(
                    WeeklyReviewResponse(
                      questionId: question.id,
                      answeredAt: now,
                      scaleValue: i,
                    ),
                  ),
                ),
              ),
          ],
        );
      case WeeklyReviewQuestionType.multiSelect:
        final selected = List<String>.from(existing?.multiSelect ?? const []);
        return Column(
          children: [
            for (final value in question.allowedValues)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilterChip(
                  label: Text(_optionLabel(loc, value)),
                  selected: selected.contains(value),
                  onSelected: (on) {
                    final next = List<String>.from(selected);
                    if (on) {
                      if (next.length >= (question.maxSelections ?? 2)) {
                        return;
                      }
                      if (!next.contains(value)) next.add(value);
                    } else {
                      next.remove(value);
                    }
                    onAnswer(
                      WeeklyReviewResponse(
                        questionId: question.id,
                        answeredAt: now,
                        multiSelect: next,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      case WeeklyReviewQuestionType.boolean_:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ChoiceChip(
                  label: Text(loc.v2WeeklyReviewYes),
                  selected: existing?.booleanValue == true,
                  onSelected: (_) => onAnswer(
                    WeeklyReviewResponse(
                      questionId: question.id,
                      answeredAt: now,
                      booleanValue: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ChoiceChip(
                  label: Text(loc.v2WeeklyReviewNo),
                  selected: existing?.booleanValue == false,
                  onSelected: (_) => onAnswer(
                    WeeklyReviewResponse(
                      questionId: question.id,
                      answeredAt: now,
                      booleanValue: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  static String _optionLabel(AppLocalizations loc, String value) {
    switch (value) {
      case 'too_light':
        return loc.v2WeeklyReviewOptTooLight;
      case 'about_right':
        return loc.v2WeeklyReviewOptAboutRight;
      case 'too_demanding':
        return loc.v2WeeklyReviewOptTooDemanding;
      case 'time':
        return loc.v2WeeklyReviewOptTime;
      case 'forgetfulness':
        return loc.v2WeeklyReviewOptForgetfulness;
      case 'low_energy':
        return loc.v2WeeklyReviewOptLowEnergy;
      case 'interruptions':
        return loc.v2WeeklyReviewOptInterruptions;
      case 'unclear_step':
        return loc.v2WeeklyReviewOptUnclearStep;
      case 'access_or_environment':
        return loc.v2WeeklyReviewOptAccessEnv;
      case 'no_major_obstacle':
        return loc.v2WeeklyReviewOptNoMajorObstacle;
      case 'shorter_path':
        return loc.v2WeeklyReviewOptShorterPath;
      case 'clearer_timing':
        return loc.v2WeeklyReviewOptClearerTiming;
      case 'quieter_environment':
        return loc.v2WeeklyReviewOptQuieterEnv;
      case 'accessibility_alternative':
        return loc.v2WeeklyReviewOptA11yAlt;
      case 'stronger_reminder':
        return loc.v2WeeklyReviewOptStrongerReminder;
      case 'same_plan_is_working':
        return loc.v2WeeklyReviewOptSamePlan;
      default:
        return value;
    }
  }
}

class _MessagePad extends StatelessWidget {
  const _MessagePad({
    required this.title,
    required this.cta,
    required this.onCta,
    this.body,
  });

  final String title;
  final String? body;
  final String cta;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 12),
                  Text(body!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(onPressed: onCta, child: Text(cta)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
