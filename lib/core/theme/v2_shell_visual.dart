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

  /// Large confident page title — primary screen identity.
  static TextStyle? pageTitle(ThemeData theme) {
    return theme.textTheme.headlineMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: AppDesignConstants.v2PageTitleSize,
      height: 1.22,
      letterSpacing: -0.2,
    );
  }

  static TextStyle? heroTitle(ThemeData theme) {
    return theme.textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.28,
    );
  }

  static TextStyle? pageSubtitle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.45,
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

  /// Eyebrow above a metric value.
  static TextStyle? metricEyebrow(ThemeData theme) {
    return theme.textTheme.labelMedium?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.25,
    );
  }

  /// Large metric number — scan-first typography.
  static TextStyle? metricValue(ThemeData theme) {
    return theme.textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: AppDesignConstants.v2MetricValueSize,
      height: AppDesignConstants.v2MetricValueHeight,
      letterSpacing: -0.3,
    );
  }

  static TextStyle? metricCaption(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
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

  static BoxDecoration heroCardDecoration() {
    return BoxDecoration(
      color: AppColors.card.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusHeroCard),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.42),
      ),
    );
  }

  static BoxDecoration infoCardDecoration() {
    return BoxDecoration(
      color: AppColors.card.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.28),
      ),
    );
  }

  static BoxDecoration settingsGroupDecoration() {
    return BoxDecoration(
      color: AppColors.card.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
      border: Border.all(
        color: AppColors.border.withValues(alpha: 0.32),
      ),
    );
  }
}

/// In-body page header — large title + optional subtitle under AppBar.
class V2PageHeader extends StatelessWidget {
  const V2PageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: V2ShellVisual.pageTitle(theme)),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppDesignConstants.v2GapTight),
          Text(subtitle!, style: V2ShellVisual.pageSubtitle(theme)),
        ],
      ],
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

/// Primary hero surface — dominant daily action / thesis / proof headline.
class V2HeroCard extends StatelessWidget {
  const V2HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: V2ShellVisual.heroCardDecoration(),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Secondary grouped information surface.
class V2InfoCard extends StatelessWidget {
  const V2InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: V2ShellVisual.infoCardDecoration(),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Compact metric — eyebrow label + large value + optional caption.
class V2MetricTile extends StatelessWidget {
  const V2MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.semanticLabel,
  });

  final String label;
  final String value;
  final String? caption;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticLabel ?? '$label: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: V2ShellVisual.metricEyebrow(theme)),
          const SizedBox(height: 4),
          Text(value, style: V2ShellVisual.metricValue(theme)),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(caption!, style: V2ShellVisual.metricCaption(theme)),
          ],
        ],
      ),
    );
  }
}

/// Horizontal row of [V2MetricTile]s with even spacing.
class V2MetricRow extends StatelessWidget {
  const V2MetricRow({super.key, required this.tiles});

  final List<V2MetricTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDesignConstants.v2GapSection),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

/// Grouped settings rows — single card, reduced nesting noise.
class V2SettingsGroup extends StatelessWidget {
  const V2SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = children.where((w) => w is! SizedBox).toList();
    return DecoratedBox(
      decoration: V2ShellVisual.settingsGroupDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.border.withValues(alpha: 0.35),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: items[i],
            ),
          ],
        ],
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
