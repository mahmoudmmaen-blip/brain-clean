import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/metric_info_row.dart';
import '../../application/bci_controller_provider.dart';
import '../../domain/bci_score_model.dart';

/// بطاقة BCI بتأثير زجاجي (Glassmorphism) وحلقة تقدم نيون/سيان.
class BciCard extends ConsumerWidget {
  const BciCard({super.key});

  static const _ringSize = 168.0;
  static const _ringStroke = 11.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bciAsync = ref.watch(bciControllerProvider);

    return bciAsync.when(
      loading: () => const _BciGlassShell(
        child: _BciLoadingContent(ringSize: BciCard._ringSize),
      ),
      error: (_, __) => const _BciGlassShell(
        child: _BciErrorContent(ringSize: BciCard._ringSize),
      ),
      data: (bci) => _BciGlassShell(
        child: _BciCardContent(
          bci: bci,
          ringSize: _ringSize,
          ringStroke: _ringStroke,
        ),
      ),
    );
  }
}

class _BciGlassShell extends StatelessWidget {
  const _BciGlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -48,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 220,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BciCardContent extends StatelessWidget {
  const _BciCardContent({
    required this.bci,
    required this.ringSize,
    required this.ringStroke,
  });

  final BciScoreModel bci;
  final double ringSize;
  final double ringStroke;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _BciNeonColors.forScore(colorScheme, bci.totalScore);
    final statusLabel = _statusLabel(loc, bci.totalScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.bciCardTitle,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: _BciNeonRing(
            progress: bci.progressRatio,
            score: bci.totalScoreRounded,
            accent: accent,
            size: ringSize,
            strokeWidth: ringStroke,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          bci.hasCommittedAssessment
              ? loc.bciCardSubtitle
              : loc.bciCardNoAssessment,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _BciStatusPill(label: statusLabel, color: accent),
        ),
        const SizedBox(height: 12),
        MetricInfoRow(
          oneLiner: loc.bciOneLiner,
          fullExplanation: loc.bciFullExplanation,
          sheetTitle: loc.bciCardTitle,
        ),
        const SizedBox(height: 18),
        Divider(color: context.borderMuted.withValues(alpha: 0.6)),
        const SizedBox(height: 14),
        _BciBreakdownRow(
          label: loc.bciCardAssessmentLabel,
          weight: loc.bciCardWeightAssessment,
          value: bci.assessmentScoreRounded,
          barColor: colorScheme.primary,
          progress: bci.assessmentScore / 100,
        ),
        const SizedBox(height: 12),
        _BciBreakdownRow(
          label: loc.bciCardAdherenceLabel,
          weight: loc.bciCardWeightAdherence,
          value: bci.adherenceScoreRounded,
          barColor: Color.lerp(colorScheme.primary, colorScheme.onSurface, 0.2)!,
          progress: bci.adherenceScore / 100,
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations loc, double score) {
    if (score >= 86) return loc.bciCardStatusHigh;
    if (score >= 71) return loc.bciCardStatusStable;
    if (score >= 41) return loc.bciCardStatusMild;
    return loc.bciCardStatusWarning;
  }
}

class _BciNeonRing extends StatelessWidget {
  const _BciNeonRing({
    required this.progress,
    required this.score,
    required this.accent,
    required this.size,
    required this.strokeWidth,
  });

  final double progress;
  final int score;
  final Color accent;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: Size(size, size),
                painter: _BciRingPainter(
                  progress: animatedProgress,
                  strokeWidth: strokeWidth,
                  accent: accent,
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$score',
              style: AppDesignConstants.arabicText(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: accent,
                height: 1,
              ),
            ),
            TextSpan(
              text: '%',
              style: AppDesignConstants.arabicText(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: accent.withValues(alpha: 0.85),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BciRingPainter extends CustomPainter {
  _BciRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.accent,
  });

  final double progress;
  final double strokeWidth;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          accent.withValues(alpha: 0.35),
          accent,
          Color.lerp(accent, Colors.white, 0.3)!,
          accent,
        ],
        stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BciRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}

class _BciBreakdownRow extends StatelessWidget {
  const _BciBreakdownRow({
    required this.label,
    required this.weight,
    required this.value,
    required this.barColor,
    required this.progress,
  });

  final String label;
  final String weight;
  final int value;
  final Color barColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppDesignConstants.arabicText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '$value · $weight',
              style: AppDesignConstants.arabicText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: barColor,
          ),
        ),
      ],
    );
  }
}

class _BciStatusPill extends StatelessWidget {
  const _BciStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppDesignConstants.arabicText(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BciLoadingContent extends StatelessWidget {
  const _BciLoadingContent({required this.ringSize});

  final double ringSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          loc.bciCardTitle,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(ringSize, ringSize),
                painter: _BciRingPainter(
                  progress: 0,
                  strokeWidth: 11,
                  accent: colorScheme.primary,
                ),
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.bciCardLoading,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textMuted,
          ),
        ),
      ],
    );
  }
}

class _BciErrorContent extends StatelessWidget {
  const _BciErrorContent({required this.ringSize});

  final double ringSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          loc.bciCardTitle,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 24),
        Icon(
          Icons.error_outline_rounded,
          size: ringSize * 0.35,
          color: AppDesignConstants.accentError.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 16),
        Text(
          loc.asyncErrorRetry,
          textAlign: TextAlign.center,
          style: AppDesignConstants.arabicText(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textMuted,
          ),
        ),
      ],
    );
  }
}

abstract final class _BciNeonColors {
  static Color forScore(ColorScheme cs, double score) {
    if (score >= 86) return cs.primary;
    if (score >= 71) return cs.primary;
    if (score >= 41) return cs.primary;
    return cs.error;
  }
}
