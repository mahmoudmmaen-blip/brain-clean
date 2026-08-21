import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../data/quick_test_results_provider.dart';
import '../domain/iq_question.dart';
import '../domain/iq_question_bank.dart';
import '../domain/quick_test_result.dart';
import '../domain/quick_test_scoring.dart';
import 'widgets/quick_test_option_list.dart';

/// Phase 5 — 5-item pattern / matrix reasoning IQ screen.
class IqTestScreen extends ConsumerStatefulWidget {
  const IqTestScreen({super.key});

  @override
  ConsumerState<IqTestScreen> createState() => _IqTestScreenState();
}

class _IqTestScreenState extends ConsumerState<IqTestScreen> {
  var _index = 0;
  final List<int?> _answers =
      List<int?>.filled(IqQuestionBank.questionCount, null);
  QuickTestResult? _result;

  IqQuestion get _question => IqQuestionBank.questions[_index];

  String _stem(AppLocalizations loc, String key) {
    return switch (key) {
      'iqQ1Stem' => loc.iqQ1Stem,
      'iqQ2Stem' => loc.iqQ2Stem,
      'iqQ3Stem' => loc.iqQ3Stem,
      'iqQ4Stem' => loc.iqQ4Stem,
      'iqQ5Stem' => loc.iqQ5Stem,
      _ => key,
    };
  }

  String _option(AppLocalizations loc, String key) {
    return switch (key) {
      'iqQ1OptA' => loc.iqQ1OptA,
      'iqQ1OptB' => loc.iqQ1OptB,
      'iqQ1OptC' => loc.iqQ1OptC,
      'iqQ1OptD' => loc.iqQ1OptD,
      'iqQ2OptA' => loc.iqQ2OptA,
      'iqQ2OptB' => loc.iqQ2OptB,
      'iqQ2OptC' => loc.iqQ2OptC,
      'iqQ2OptD' => loc.iqQ2OptD,
      'iqQ3OptA' => loc.iqQ3OptA,
      'iqQ3OptB' => loc.iqQ3OptB,
      'iqQ3OptC' => loc.iqQ3OptC,
      'iqQ3OptD' => loc.iqQ3OptD,
      'iqQ4OptA' => loc.iqQ4OptA,
      'iqQ4OptB' => loc.iqQ4OptB,
      'iqQ4OptC' => loc.iqQ4OptC,
      'iqQ4OptD' => loc.iqQ4OptD,
      'iqQ5OptA' => loc.iqQ5OptA,
      'iqQ5OptB' => loc.iqQ5OptB,
      'iqQ5OptC' => loc.iqQ5OptC,
      'iqQ5OptD' => loc.iqQ5OptD,
      _ => key,
    };
  }

  Future<void> _finish() async {
    final resolved = _answers.map((a) => a!).toList(growable: false);
    final scored = QuickTestScorer.scoreIq(resolved);
    await ref.read(quickTestResultsProvider.notifier).record(scored);
    if (!mounted) return;
    setState(() => _result = scored);
  }

  void _advance() {
    if (_answers[_index] == null) return;
    if (_index >= IqQuestionBank.questionCount - 1) {
      _finish();
      return;
    }
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_result != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(loc.iqTestTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: V2ShellVisual.pagePadding(top: 8),
          children: [
            Text(
              loc.iqTestResultTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            V2InfoCard(
              child: Column(
                children: [
                  Text(
                    '${_result!.scorePercent}%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.iqTestResultDetail(
                      _result!.correctCount ?? 0,
                      _result!.totalCount ?? IqQuestionBank.questionCount,
                    ),
                    style: V2ShellVisual.bodyMuted(theme),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            Text(
              loc.iqTestDisclaimer,
              style: V2ShellVisual.captionMuted(theme),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            FilledButton(
              onPressed: () => context.go(AppRoutes.v2Home),
              child: Text(loc.iqTestDone),
            ),
          ],
        ),
      );
    }

    final q = _question;
    final labels = q.optionKeys.map((k) => _option(loc, k)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.iqTestTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_index > 0) {
              setState(() => _index -= 1);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: ListView(
        padding: V2ShellVisual.pagePadding(top: 8),
        children: [
          Text(
            loc.quickTestProgress(
              _index + 1,
              IqQuestionBank.questionCount,
            ),
            style: V2ShellVisual.captionMuted(theme),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          LinearProgressIndicator(
            value: (_index + 1) / IqQuestionBank.questionCount,
            backgroundColor: AppColors.card,
            color: AppColors.primary,
            minHeight: 6,
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          Text(
            _stem(loc, q.stemKey),
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          QuickTestOptionList(
            labels: labels,
            selectedIndex: _answers[_index],
            onSelected: (i) => setState(() => _answers[_index] = i),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          FilledButton(
            onPressed: _answers[_index] == null ? null : _advance,
            child: Text(
              _index >= IqQuestionBank.questionCount - 1
                  ? loc.iqTestFinish
                  : loc.iqTestContinue,
            ),
          ),
        ],
      ),
    );
  }
}
