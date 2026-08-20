import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../domain/diag_question.dart';
import '../domain/diag_question_bank.dart';
import 'widgets/diag_answer_options.dart';
import 'widgets/diag_progress_dots.dart';

class DiagQView extends StatelessWidget {
  const DiagQView({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.selected,
    required this.canAdvance,
    required this.isLastQuestion,
    required this.onSelect,
    required this.onBack,
    required this.onContinue,
  });

  final DiagQuestion question;
  final int questionIndex;
  final int? selected;
  final bool canAdvance;
  final bool isLastQuestion;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  String _stemFor(DiagQuestion q, AppLocalizations loc) {
    return switch (q.stemKey) {
      'diagQ1Stem' => loc.diagQ1Stem,
      'diagQ2Stem' => loc.diagQ2Stem,
      'diagQ3Stem' => loc.diagQ3Stem,
      'diagQ4Stem' => loc.diagQ4Stem,
      'diagQ5Stem' => loc.diagQ5Stem,
      _ => q.stemKey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: V2ShellVisual.pagePadding(top: 8),
      children: [
        DiagProgressDots(
          total: DiagQuestionBank.questionCount,
          currentIndex: questionIndex,
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        Text(
          loc.diagQuestionProgress(
            questionIndex + 1,
            DiagQuestionBank.questionCount,
          ),
          style: V2ShellVisual.captionMuted(theme),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDesignConstants.v2GapControl),
        Semantics(
          header: true,
          child: Text(
            _stemFor(question, loc),
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        DiagAnswerOptions(
          loc: loc,
          selected: selected,
          onSelected: onSelect,
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        Row(
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(loc.diagBack),
            ),
            const Spacer(),
            FilledButton(
              onPressed: canAdvance ? onContinue : null,
              child: Text(
                isLastQuestion ? loc.diagFinish : loc.diagContinue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
