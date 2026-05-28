import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_session.dart';
import '../brain_rot_localization.dart';
import '../diagnostic_session_flow_provider.dart';
import 'brain_rot_question_page.dart';
import 'brain_rot_step_indicator.dart';

/// Brain Rot 10-question flow — driven by [DiagnosticSession.inProgress].
class BrainRotQuestionnaireView extends ConsumerWidget {
  const BrainRotQuestionnaireView({
    super.key,
    required this.session,
  });

  final DiagnosticSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final flow = ref.read(diagnosticSessionFlowProvider.notifier);
    final questionnaire = ref.watch(diagnosticSessionFlowProvider);
    final index = questionnaire.currentIndex;
    final slideDirection = flow.questionSlideDirection;
    final answersEnabled = !questionnaire.isInteractionLocked;
    final pendingResults = questionnaire.pendingResultsTransition;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignConstants.radiusCard + 6,
        vertical: 16,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              BrainRotStepIndicator(
                currentIndex: index,
                answers: questionnaire.answers,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BrainRotQuestionPage(
                  key: ValueKey<int>(index),
                  questionIndex: index,
                  questionText: brainRotQuestionFor(context, loc, index),
                  slideDirection: slideDirection,
                  answersEnabled: answersEnabled,
                  onAnswer: (yes) => flow.answerQuestion(index, yes),
                  onBack: answersEnabled && index > 0
                      ? () => flow.goToQuestion(index - 1)
                      : null,
                ),
              ),
            ],
          ),
          if (pendingResults)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.72),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: context.brandPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.diagnosticBrainRotScoring,
                          textAlign: TextAlign.center,
                          style: context.arabicLabelStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
