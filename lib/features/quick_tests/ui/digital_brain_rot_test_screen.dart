import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../data/quick_test_results_provider.dart';
import '../domain/digital_brain_rot_question.dart';
import '../domain/digital_brain_rot_question_bank.dart';
import '../domain/quick_test_result.dart';
import '../domain/quick_test_scoring.dart';
import 'widgets/quick_test_option_list.dart';

/// Phase 5 — 8-item digital brain-rot / screen-habits screen.
class DigitalBrainRotTestScreen extends ConsumerStatefulWidget {
  const DigitalBrainRotTestScreen({super.key});

  @override
  ConsumerState<DigitalBrainRotTestScreen> createState() =>
      _DigitalBrainRotTestScreenState();
}

class _DigitalBrainRotTestScreenState
    extends ConsumerState<DigitalBrainRotTestScreen> {
  var _index = 0;
  final List<int?> _answers =
      List<int?>.filled(DigitalBrainRotQuestionBank.questionCount, null);
  QuickTestResult? _result;

  DigitalBrainRotQuestion get _question =>
      DigitalBrainRotQuestionBank.questions[_index];

  String _stem(AppLocalizations loc, String key) {
    return switch (key) {
      'digitalBrainRotQ1Stem' => loc.digitalBrainRotQ1Stem,
      'digitalBrainRotQ2Stem' => loc.digitalBrainRotQ2Stem,
      'digitalBrainRotQ3Stem' => loc.digitalBrainRotQ3Stem,
      'digitalBrainRotQ4Stem' => loc.digitalBrainRotQ4Stem,
      'digitalBrainRotQ5Stem' => loc.digitalBrainRotQ5Stem,
      'digitalBrainRotQ6Stem' => loc.digitalBrainRotQ6Stem,
      'digitalBrainRotQ7Stem' => loc.digitalBrainRotQ7Stem,
      'digitalBrainRotQ8Stem' => loc.digitalBrainRotQ8Stem,
      _ => key,
    };
  }

  Future<void> _finish() async {
    final resolved = _answers.map((a) => a!).toList(growable: false);
    final scored = QuickTestScorer.scoreDigitalBrainRot(resolved);
    await ref.read(quickTestResultsProvider.notifier).record(scored);
    ref.invalidate(homeDashboardProvider);
    if (!mounted) return;
    setState(() => _result = scored);
  }

  void _advance() {
    if (_answers[_index] == null) return;
    if (_index >= DigitalBrainRotQuestionBank.questionCount - 1) {
      _finish();
      return;
    }
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final likert = quickTestLikertOptions(loc);

    if (_result != null) {
      final rotHint = _result!.scorePercent >= 70
          ? loc.digitalBrainRotResultHealthy
          : _result!.scorePercent >= 40
              ? loc.digitalBrainRotResultModerate
              : loc.digitalBrainRotResultHigh;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(loc.digitalBrainRotTestTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: V2ShellVisual.pagePadding(top: 8),
          children: [
            Text(
              loc.digitalBrainRotResultTitle,
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
                    loc.digitalBrainRotResultClarityLabel,
                    style: V2ShellVisual.captionMuted(theme),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rotHint,
                    style: V2ShellVisual.bodyMuted(theme),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            Text(
              loc.digitalBrainRotDisclaimer,
              style: V2ShellVisual.captionMuted(theme),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            FilledButton(
              onPressed: () => context.go(AppRoutes.v2Home),
              child: Text(loc.digitalBrainRotDone),
            ),
          ],
        ),
      );
    }

    final q = _question;
    final selectedLikert = _answers[_index];
    final selectedIndex =
        selectedLikert == null ? null : selectedLikert - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.digitalBrainRotTestTitle),
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
              DigitalBrainRotQuestionBank.questionCount,
            ),
            style: V2ShellVisual.captionMuted(theme),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignConstants.v2GapControl),
          LinearProgressIndicator(
            value: (_index + 1) / DigitalBrainRotQuestionBank.questionCount,
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
            labels: likert.map((e) => e.$2).toList(),
            selectedIndex: selectedIndex,
            onSelected: (i) => setState(() => _answers[_index] = i + 1),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          FilledButton(
            onPressed: _answers[_index] == null ? null : _advance,
            child: Text(
              _index >= DigitalBrainRotQuestionBank.questionCount - 1
                  ? loc.digitalBrainRotFinish
                  : loc.digitalBrainRotContinue,
            ),
          ),
        ],
      ),
    );
  }
}
