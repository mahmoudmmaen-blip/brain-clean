import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Full-screen overlay while [PillarBoundEvaluation] and coherence checks finalize
/// after the 10th Brain Rot answer, before the interpretation dashboard appears.
///
/// Place above the active diagnostic body (e.g. via [Stack]) with [visible] driven
/// by [BrainRotQuestionnaireSnapshot.pendingResultsTransition].
class BrainRotScoringLoadingOverlay extends StatelessWidget {
  const BrainRotScoringLoadingOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.92),
                  theme.colorScheme.surface.withValues(alpha: 0.96),
                ],
              ),
            ),
            child: Center(
              child: Directionality(
                textDirection:
                    isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Card(
                    elevation: context.isLightTheme ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDesignConstants.radiusCard + 4,
                      ),
                      side: BorderSide(
                        color: context.brandPrimary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDesignConstants.radiusCard + 4,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            context.brandPrimary.withValues(alpha: 0.08),
                            theme.cardTheme.color ??
                                theme.colorScheme.surface,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 36,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology_alt_outlined,
                              size: 36,
                              color: context.brandPrimary,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: context.brandPrimary,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              loc.diagnosticBrainRotScoring,
                              textAlign: TextAlign.center,
                              style: context.arabicLabelStyle.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
