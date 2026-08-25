import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_design_constants.dart';
import 'app_palette.dart';

/// Quiet shared presentation helpers for the V2 five-tab shell.
///
/// Visual only — no routing or business logic.
/// Colors resolve from [AppPalette] on [ThemeData] so theme modes
/// (Dark / Light / AMOLED / Pure White / Warm Beige) switch immediately.
abstract final class V2ShellVisual {
  static AppPalette _palette([ThemeData? theme]) =>
      theme != null ? AppColors.fromTheme(theme) : AppPalette.dark;

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
    final p = _palette(theme);
    return theme.textTheme.headlineMedium?.copyWith(
      color: p.textPrimary,
      fontWeight: FontWeight.w800,
      fontSize: AppDesignConstants.typeH1,
      height: 40 / 32,
      letterSpacing: -0.4,
    );
  }

  static TextStyle? heroTitle(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.headlineSmall?.copyWith(
      color: p.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: AppDesignConstants.typeH2,
      height: 32 / 24,
    );
  }

  static TextStyle? pageSubtitle(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
      fontSize: AppDesignConstants.typeBody,
      height: 24 / 16,
    );
  }

  static TextStyle? sectionLabel(ThemeData theme) {
    return theme.textTheme.labelLarge?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w800,
      fontSize: AppDesignConstants.typeCaption,
      letterSpacing: 0.2,
      height: 20 / 14,
    );
  }

  static TextStyle? bodyMuted(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
      fontSize: AppDesignConstants.typeBody,
      height: 24 / 16,
    );
  }

  static TextStyle? captionMuted(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.bodySmall?.copyWith(
      color: p.textSecondary,
      fontSize: AppDesignConstants.typeCaption,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
    );
  }

  /// Eyebrow above a metric value.
  static TextStyle? metricEyebrow(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.labelMedium?.copyWith(
      color: p.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.35,
      height: 1.3,
    );
  }

  /// Large metric number — scan-first typography.
  static TextStyle? metricValue(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.headlineSmall?.copyWith(
      color: p.textPrimary,
      fontWeight: FontWeight.w800,
      fontSize: AppDesignConstants.v2MetricValueSize,
      height: AppDesignConstants.v2MetricValueHeight,
      letterSpacing: -0.8,
    );
  }

  static TextStyle? metricCaption(ThemeData theme) {
    final p = _palette(theme);
    return theme.textTheme.bodySmall?.copyWith(
      color: p.textSecondary,
      height: 1.35,
    );
  }

  static ButtonStyle primaryFilled() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
      ),
    );
  }

  static ButtonStyle secondaryOutlined([ThemeData? theme]) {
    final p = _palette(theme);
    return OutlinedButton.styleFrom(
      foregroundColor: p.textPrimary,
      side: BorderSide(color: p.border),
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
      ),
    );
  }

  static ButtonStyle tertiaryText([ThemeData? theme]) {
    final p = _palette(theme);
    return TextButton.styleFrom(
      foregroundColor: p.textSecondary,
      minimumSize: const Size(
        AppDesignConstants.minTouchTarget,
        AppDesignConstants.minTouchTarget,
      ),
    );
  }

  static BoxDecoration heroCardDecoration([ThemeData? theme]) {
    final p = _palette(theme);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          p.heroGradientTop,
          p.heroGradientBottom,
        ],
      ),
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusHeroCard),
      border: Border.all(color: p.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Mint pill tag — mock `.hero-tag` / `.badge.free`.
  static BoxDecoration mintTagDecoration([ThemeData? theme]) {
    final p = _palette(theme);
    return BoxDecoration(
      color: p.primaryDim,
      borderRadius: BorderRadius.circular(20),
    );
  }

  static TextStyle? mintTagLabel(ThemeData theme) {
    return theme.textTheme.labelMedium?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      height: 1.2,
    );
  }

  /// Gold Pro pill — mock `.badge.pro`.
  static BoxDecoration goldTagDecoration() {
    return BoxDecoration(
      color: AppColors.goldDim,
      borderRadius: BorderRadius.circular(20),
    );
  }

  static TextStyle? goldTagLabel(ThemeData theme) {
    return theme.textTheme.labelMedium?.copyWith(
      color: AppColors.goldText,
      fontWeight: FontWeight.w700,
      fontSize: 10.5,
      height: 1.2,
    );
  }

  /// Large mint metric — mock `.hero-num`.
  static TextStyle? heroMetricValue(ThemeData theme) {
    return theme.textTheme.headlineLarge?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w900,
      fontSize: AppDesignConstants.v2MetricHeroSize,
      height: 1.05,
      letterSpacing: -1.2,
    );
  }

  static BoxDecoration infoCardDecoration([ThemeData? theme]) {
    final p = _palette(theme);
    return BoxDecoration(
      color: p.card,
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
      border: Border.all(color: p.border, width: 1),
      boxShadow: [
        ...AppColors.primaryGlow,
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration settingsGroupDecoration([ThemeData? theme]) {
    final p = _palette(theme);
    return BoxDecoration(
      color: p.card,
      borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
      border: Border.all(color: p.border, width: 1),
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
  const V2SectionLabel(
    this.label, {
    super.key,
    this.emphasized = false,
  });

  final String label;
  /// Mint/green accent for prominent home section titles.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Text(
        label,
        style: emphasized
            ? TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.3,
                letterSpacing: 0.1,
              )
            : V2ShellVisual.sectionLabel(theme),
      ),
    );
  }
}

/// Primary hero surface — dominant daily action / thesis / proof headline.
class V2HeroCard extends StatelessWidget {
  const V2HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignConstants.v2HeroPad),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: V2ShellVisual.heroCardDecoration(Theme.of(context)),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Secondary grouped information surface.
class V2InfoCard extends StatelessWidget {
  const V2InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignConstants.v2InfoPad),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: V2ShellVisual.infoCardDecoration(Theme.of(context)),
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
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: V2ShellVisual.metricValue(theme)),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: 6),
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
    final theme = Theme.of(context);
    final p = AppColors.fromTheme(theme);
    final items = children.where((w) => w is! SizedBox).toList();
    return DecoratedBox(
      decoration: V2ShellVisual.settingsGroupDecoration(theme),
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
                color: p.border.withValues(alpha: 0.35),
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

/// Tappable settings row used inside [V2SettingsGroup].
class V2SettingsRow extends StatelessWidget {
  const V2SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppColors.fromTheme(theme);
    final titleColor = destructive ? AppColors.danger : p.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDesignConstants.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppDesignConstants.v2GapTight),
                  trailing!,
                ] else if (showChevron && onTap != null) ...[
                  const SizedBox(width: AppDesignConstants.v2GapTight),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: p.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch row used inside [V2SettingsGroup].
class V2SettingsSwitchRow extends StatelessWidget {
  const V2SettingsSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return V2SettingsRow(
      title: title,
      subtitle: subtitle,
      showChevron: false,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(
        value: value,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.38),
        onChanged: onChanged,
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
    final p = AppColors.fromTheme(theme);
    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
          border: Border.all(color: p.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: p.textPrimary,
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
    final p = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        border: Border.all(color: p.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
