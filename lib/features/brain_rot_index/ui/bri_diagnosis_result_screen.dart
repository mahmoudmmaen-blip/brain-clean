import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../cognitive_tests/application/cognitive_test_results_provider.dart';
import '../../daily_program/domain/adaptive_program_engine.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../quick_tests/data/quick_test_results_provider.dart';
import '../domain/bri_axis.dart';
import '../domain/bri_program_recommendation.dart';
import '../domain/bri_result.dart';
import 'widgets/bri_radar_chart.dart';

/// Post-BRI results: radar, score ring, severe warning, recommended program.
class BriDiagnosisResultScreen extends ConsumerWidget {
  const BriDiagnosisResultScreen({
    super.key,
    required this.result,
  });

  final BriResult result;

  String _bandLabel(AppLocalizations loc, BriBand band) {
    return switch (band) {
      BriBand.healthy => loc.briBandHealthy,
      BriBand.mild => loc.briBandMild,
      BriBand.moderate => loc.briBandModerate,
      BriBand.severe => loc.briBandSevere,
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

  String _resolve(AppLocalizations loc, String key) {
    return switch (key) {
      'adaptiveProgramResetTitle' => loc.adaptiveProgramResetTitle,
      'adaptiveProgramAscensionTitle' => loc.adaptiveProgramAscensionTitle,
      'adaptiveProgramEnhancedMindTitle' =>
        loc.adaptiveProgramEnhancedMindTitle,
      'adaptiveProgramBaseTitle' => loc.adaptiveProgramBaseTitle,
      'briRecommendResetBody' => loc.briRecommendResetBody,
      'briRecommendAscensionBody' => loc.briRecommendAscensionBody,
      'briRecommendEnhancedBody' => loc.briRecommendEnhancedBody,
      'briRecommendBaseBody' => loc.briRecommendBaseBody,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final isPro = ref.watch(isProUserProvider);
    final cognitive = ref.watch(cognitiveTestResultsProvider);
    final quick = ref.watch(quickTestResultsProvider);

    final focus = cognitive.visualAttention?.normalizedScore.round();
    final memory = cognitive.memorySequence?.normalizedScore.round();
    final iq = quick.iq?.scorePercent;
    final hasCognitive = focus != null || memory != null || iq != null;

    final recommendation = BriProgramRecommender.recommend(
      bri: result,
      isPro: isPro,
      focusScore: focus ?? 55,
      memoryScore: memory ?? 55,
      iqScore: iq ?? 55,
      hasCognitiveTests: hasCognitive,
    );

    final bri = result.overallScore;
    final color = briSeverityColor(bri);
    final isSevere = bri > AdaptiveProgramEngine.briHighThreshold;

    // Radar: health scores (higher = healthier). 5 spokes when cognition present.
    final List<double> radarValues;
    final List<String> radarLabels;
    if (hasCognitive) {
      radarValues = [
        result.clarityScore.toDouble(),
        (memory ?? 50).toDouble(),
        (focus ?? 50).toDouble(),
        (iq ?? 50).toDouble(),
        // Sleep proxy: boredom-resistance clarity until sleep battery ships.
        (100 - (result.axisScores[BriAxis.boredomResistance] ?? 50))
            .toDouble(),
      ];
      radarLabels = [
        loc.briRadarRot,
        loc.briRadarMemory,
        loc.briRadarFocus,
        loc.briRadarIq,
        loc.briRadarSleep,
      ];
    } else {
      radarValues = briAxesToHealthValues([
        for (final axis in BriAxis.values) result.axisScores[axis] ?? 50,
      ]);
      radarLabels = [
        for (final axis in BriAxis.values) _axisTitle(loc, axis),
      ];
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        title: Text(loc.briTestTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.v2Home),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          children: [
            Text(
              loc.briResultTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.briScoreLabel,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            BriSevereGlow(
              severe: isSevere,
              child: SizedBox(
                height: 280,
                child: BriRadarChart(
                  values: radarValues,
                  labels: radarLabels,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.1),
                      border: Border.all(color: color, width: 3),
                      boxShadow: isSevere
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '$bri',
                      style: TextStyle(
                        color: color,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _bandLabel(loc, result.band),
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (isSevere) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDesignConstants.radiusButton),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.briSevereWarningBody,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDesignConstants.paddingCard),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius:
                    BorderRadius.circular(AppDesignConstants.radiusCard),
                border: recommendation.isProRequired
                    ? Border.all(color: AppColors.gold, width: 2)
                    : Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (recommendation.isProRequired)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          loc.briProBadge,
                          style: const TextStyle(
                            color: AppColors.goldText,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (recommendation.isProRequired) const SizedBox(height: 8),
                  Text(
                    _resolve(loc, recommendation.titleKey),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _resolve(loc, recommendation.descriptionKey),
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: AppDesignConstants.minTouchTarget,
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.v2DailyProgram),
                style: V2ShellVisual.primaryFilled(),
                child: Text(
                  isPro
                      ? loc.briGenerateProgramCta
                      : loc.briStartResetCta,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!isPro) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.push(
                  AppRoutes.v2PremiumWithSource('bri_result'),
                ),
                child: Text(
                  loc.briUnlockProProgramCta,
                  style: const TextStyle(
                    color: AppColors.goldText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              loc.briDisclaimer,
              textAlign: TextAlign.center,
              style: V2ShellVisual.captionMuted(theme),
            ),
          ],
        ),
      ),
    );
  }
}
