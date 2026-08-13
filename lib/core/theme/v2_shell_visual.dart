import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_design_constants.dart';

/// Quiet shared presentation helpers for the V2 four-tab shell.
///
/// Visual only — no routing or business logic.
abstract final class V2ShellVisual {
  static EdgeInsets pagePadding({
    double top = AppDesignConstants.v2PadTop,
    double bottom = AppDesignConstants.v2PadBottom,
  }) {
    return EdgeInsets.fromLTRB(
      AppDesignConstants.v2PadH,
      top,
      AppDesignConstants.v2PadH,
      bottom,
    );
  }

  static TextStyle? heroTitle(ThemeData theme) {
    return theme.textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.28,
    );
  }

  static TextStyle? sectionLabel(ThemeData theme) {
    return theme.textTheme.labelLarge?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.3,
    );
  }

  static TextStyle? bodyMuted(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
  }

  static TextStyle? captionMuted(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.4,
    );
  }

  static ButtonStyle primaryFilled() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
      ),
    );
  }

  static ButtonStyle secondaryOutlined() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      side: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
      ),
    );
  }

  static ButtonStyle tertiaryText() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
    );
  }
}

/// Level-3 section title used across Profile / Progress / Program.
class V2SectionLabel extends StatelessWidget {
  const V2SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: V2ShellVisual.sectionLabel(Theme.of(context)),
      ),
    );
  }
}

/// Compact, quiet status chip — not a peer card.
class V2QuietChip extends StatelessWidget {
  const V2QuietChip({
    super.key,
    required this.label,
    this.semanticLabel,
  });

  final String label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft tonal surface for optional grouping (not a heavy Material card).
class V2TonalSurface extends StatelessWidget {
  const V2TonalSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
