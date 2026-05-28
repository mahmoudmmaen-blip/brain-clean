import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Full-screen overlay while pillar-bound evaluation and coherence finalize
/// after the 10th Brain Rot answer, before the interpretation dashboard appears.
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

    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: ColoredBox(
            color: theme.colorScheme.surface.withValues(alpha: 0.88),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Card(
                  elevation: context.isLightTheme ? 3 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignConstants.radiusCard,
                    ),
                    side: BorderSide(
                      color: context.brandPrimary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: context.brandPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          loc.diagnosticBrainRotScoring,
                          textAlign: TextAlign.center,
                          style: context.arabicLabelStyle.copyWith(
                            fontWeight: FontWeight.w600,
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
    );
  }
}
