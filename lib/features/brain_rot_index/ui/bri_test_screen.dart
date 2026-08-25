import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../quick_tests/ui/widgets/quick_test_option_list.dart';
import '../data/bri_results_provider.dart';
import '../domain/bri_axis.dart';
import '../domain/bri_question.dart';
import '../domain/bri_question_bank.dart';
import '../domain/bri_result.dart';
import '../domain/bri_scorer.dart';

/// Free Brain Rot Index — 16 Likert items across 4 axes (7-day retake).
class BriTestScreen extends ConsumerStatefulWidget {
  const BriTestScreen({super.key});

  @override
  ConsumerState<BriTestScreen> createState() => _BriTestScreenState();
}

class _BriTestScreenState extends ConsumerState<BriTestScreen> {
  var _index = 0;
  final List<int?> _answers =
      List<int?>.filled(BriQuestionBank.questionCount, null);
  BriResult? _result;

  BriQuestion get _question => BriQuestionBank.questions[_index];

  String _stem(AppLocalizations loc, String key) {
    return switch (key) {
      'briQShortForm1' => loc.briQShortForm1,
      'briQShortForm2' => loc.briQShortForm2,
      'briQShortForm3' => loc.briQShortForm3,
      'briQShortForm4' => loc.briQShortForm4,
      'briQAttention1' => loc.briQAttention1,
      'briQAttention2' => loc.briQAttention2,
      'briQAttention3' => loc.briQAttention3,
      'briQAttention4' => loc.briQAttention4,
      'briQInfoFatigue1' => loc.briQInfoFatigue1,
      'briQInfoFatigue2' => loc.briQInfoFatigue2,
      'briQInfoFatigue3' => loc.briQInfoFatigue3,
      'briQInfoFatigue4' => loc.briQInfoFatigue4,
      'briQBoredom1' => loc.briQBoredom1,
      'briQBoredom2' => loc.briQBoredom2,
      'briQBoredom3' => loc.briQBoredom3,
      'briQBoredom4' => loc.briQBoredom4,
      _ => key,
    };
  }

  String _axisTitle(AppLocalizations loc, BriAxis axis) {
    return switch (axis) {
      BriAxis.shortFormAddiction => loc.briAxisShortForm,
      BriAxis.attentionScatter => loc.briAxisAttention,
      BriAxis.infoFatigue => loc.briAxisInfoFatigue,
      BriAxis.boredomResistance => loc.briAxisBoredom,
    };
  }

  String _bandLabel(AppLocalizations loc, BriBand band) {
    return switch (band) {
      BriBand.healthy => loc.briBandHealthy,
      BriBand.mild => loc.briBandMild,
      BriBand.moderate => loc.briBandModerate,
      BriBand.severe => loc.briBandSevere,
    };
  }

  Color _bandColor(BriBand band) {
    return switch (band) {
      BriBand.healthy => AppColors.positive,
      BriBand.mild => AppColors.warning,
      BriBand.moderate => AppColors.accentOrange,
      BriBand.severe => AppColors.danger,
    };
  }

  Future<void> _finish() async {
    final resolved = _answers.map((a) => a!).toList(growable: false);
    final scored = BriScorer.score(resolved);
    await persistBriAndMirrorDigital(ref: ref, bri: scored);
    ref.invalidate(homeDashboardProvider);
    if (!mounted) return;
    setState(() => _result = scored);
  }

  void _advance() {
    if (_answers[_index] == null) return;
    if (_index >= BriQuestionBank.questionCount - 1) {
      _finish();
      return;
    }
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final latest = ref.watch(briResultsProvider);
    final daysLeft = BriScorer.daysUntilRetest(latest);
    final locked = latest != null && daysLeft > 0;

    if (_result != null) {
      return _ResultView(
        loc: loc,
        theme: theme,
        result: _result!,
        axisTitle: _axisTitle,
        bandLabel: _bandLabel,
        bandColor: _bandColor,
      );
    }

    if (locked) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(loc.briTestTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: V2ShellVisual.pagePadding(top: 8),
          children: [
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.briCooldownTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.briCooldownBody(daysLeft),
                    style: V2ShellVisual.bodyMuted(theme),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.briLastScoreLabel(latest.overallScore),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bandLabel(loc, latest.band),
                    style: TextStyle(
                      color: _bandColor(latest.band),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.v2Home),
                    child: Text(loc.briDoneCta),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final likert = quickTestLikertOptions(loc);
    final progress = (_index + 1) / BriQuestionBank.questionCount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.briTestTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: V2ShellVisual.pagePadding(top: 8),
        children: [
          Text(
            loc.briTestSubtitle,
            style: V2ShellVisual.bodyMuted(theme),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.of(context).cardSecondary,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.briProgressLabel(_index + 1, BriQuestionBank.questionCount),
            style: V2ShellVisual.captionMuted(theme),
          ),
          const SizedBox(height: 16),
          Text(
            _axisTitle(loc, _question.axis),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _stem(loc, _question.stemKey),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.4,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          QuickTestOptionList(
            labels: likert.map((e) => e.$2).toList(growable: false),
            selectedIndex: _answers[_index] == null
                ? null
                : likert.indexWhere((e) => e.$1 == _answers[_index]),
            onSelected: (i) {
              setState(() => _answers[_index] = likert[i].$1);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: FilledButton(
              onPressed: _answers[_index] == null ? null : _advance,
              style: V2ShellVisual.primaryFilled(),
              child: Text(
                _index >= BriQuestionBank.questionCount - 1
                    ? loc.briFinishCta
                    : loc.briContinueCta,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.briDisclaimer,
            style: V2ShellVisual.captionMuted(theme),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.loc,
    required this.theme,
    required this.result,
    required this.axisTitle,
    required this.bandLabel,
    required this.bandColor,
  });

  final AppLocalizations loc;
  final ThemeData theme;
  final BriResult result;
  final String Function(AppLocalizations, BriAxis) axisTitle;
  final String Function(AppLocalizations, BriBand) bandLabel;
  final Color Function(BriBand) bandColor;

  @override
  Widget build(BuildContext context) {
    final band = result.band;
    final color = bandColor(band);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.briTestTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.v2Home),
        ),
      ),
      body: ListView(
        padding: V2ShellVisual.pagePadding(top: 8),
        children: [
          Text(
            loc.briResultTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          V2InfoCard(
            child: Column(
              children: [
                Text(
                  '${result.overallScore}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.briScoreLabel,
                  style: V2ShellVisual.captionMuted(theme),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    bandLabel(loc, band),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          Text(
            loc.briAxesHeading,
            style: V2ShellVisual.sectionLabel(theme),
          ),
          const SizedBox(height: 10),
          for (final axis in BriAxis.values) ...[
            _AxisBar(
              label: axisTitle(loc, axis),
              score: result.axisScores[axis] ?? 0,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Text(
            loc.briDisclaimer,
            style: V2ShellVisual.captionMuted(theme),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: FilledButton(
              onPressed: () => context.go(AppRoutes.v2Home),
              style: V2ShellVisual.primaryFilled(),
              child: Text(loc.briDoneCta),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisBar extends StatelessWidget {
  const _AxisBar({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return V2InfoCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$score',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: palette.cardSecondary,
              color: score <= 30
                  ? AppColors.positive
                  : score <= 60
                      ? AppColors.warning
                      : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
