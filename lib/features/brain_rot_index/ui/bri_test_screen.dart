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
import 'bri_diagnosis_result_screen.dart';

/// Interactive BRI diagnosis — one question per screen, fade + auto-advance.
class BriTestScreen extends ConsumerStatefulWidget {
  const BriTestScreen({super.key});

  @override
  ConsumerState<BriTestScreen> createState() => _BriTestScreenState();
}

class _BriTestScreenState extends ConsumerState<BriTestScreen>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  final List<int?> _answers =
      List<int?>.filled(BriQuestionBank.questionCount, null);
  BriResult? _result;
  var _finishing = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  BriQuestion get _question => BriQuestionBank.questions[_index];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
      BriBand.healthy => AppColors.success,
      BriBand.mild => AppColors.warning,
      BriBand.moderate => AppColors.accentOrange,
      BriBand.severe => AppColors.danger,
    };
  }

  Future<void> _answerQuestion(int likertValue) async {
    if (_finishing) return;
    setState(() => _answers[_index] = likertValue);

    if (_index >= BriQuestionBank.questionCount - 1) {
      await _finishTest();
      return;
    }

    await _animController.reverse();
    if (!mounted) return;
    setState(() => _index += 1);
    await _animController.forward();
  }

  Future<void> _finishTest() async {
    if (_finishing) return;
    _finishing = true;
    try {
      final resolved = _answers.map((a) => a!).toList(growable: false);
      final scored = BriScorer.score(resolved);
      await persistBriAndMirrorDigital(ref: ref, bri: scored);
      ref.invalidate(homeDashboardProvider);
      if (!mounted) return;
      setState(() => _result = scored);
    } catch (_) {
      _finishing = false;
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.briDisclaimer)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final latest = ref.watch(briResultsProvider);
    final daysLeft = BriScorer.daysUntilRetest(latest);
    final locked = latest != null && daysLeft > 0;

    if (_result != null) {
      return BriDiagnosisResultScreen(result: _result!);
    }

    if (locked) {
      return Scaffold(
        backgroundColor: palette.background,
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
                      color: palette.textPrimary,
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
    final total = BriQuestionBank.questionCount;
    final progress = (_index + 1) / total;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        title: Text(loc.briTestTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDesignConstants.radiusPill),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: palette.cardSecondary,
                  color: AppColors.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.briProgressLabel(_index + 1, total),
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _axisTitle(loc, _question.axis),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _stem(loc, _question.stemKey),
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 36),
                        for (var i = 0; i < likert.length; i++) ...[
                          _AnswerButton(
                            label: '${likert[i].$1} — ${likert[i].$2}',
                            delay: i * 0.08,
                            animation: _fadeAnimation,
                            onTap: () => _answerQuestion(likert[i].$1),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          loc.briDisclaimer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textTertiary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.onTap,
    required this.animation,
    required this.delay,
  });

  final String label;
  final VoidCallback onTap;
  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDesignConstants.minTouchTarget,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDesignConstants.radiusButton),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
