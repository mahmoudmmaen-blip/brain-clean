import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';

/// Marketing plan cards — monthly (gold) and annual saver.
class PremiumPlanCards extends StatelessWidget {
  const PremiumPlanCards({
    super.key,
    required this.loc,
    required this.selectedPlan,
    required this.onSelectMonthly,
    required this.onSelectAnnual,
  });

  final AppLocalizations loc;
  final PremiumPlanChoice selectedPlan;
  final VoidCallback onSelectMonthly;
  final VoidCallback onSelectAnnual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanCard(
          title: loc.v2PremiumPlanMonthlyTitle,
          price: loc.v2PremiumPlanMonthlyPrice,
          subtitle: loc.v2PremiumPlanMonthlySubtitle,
          selected: selectedPlan == PremiumPlanChoice.monthly,
          highlighted: true,
          onTap: onSelectMonthly,
        ),
        const SizedBox(height: AppDesignConstants.v2GapControl),
        _PlanCard(
          title: loc.v2PremiumPlanAnnualTitle,
          price: loc.v2PremiumPlanAnnualPrice,
          subtitle: loc.v2PremiumPlanAnnualSubtitle,
          badge: loc.v2PremiumPlanAnnualBadge,
          selected: selectedPlan == PremiumPlanChoice.annual,
          highlighted: false,
          onTap: onSelectAnnual,
        ),
        const SizedBox(height: AppDesignConstants.v2GapSection),
        Text(
          loc.v2PremiumFeaturesHeading,
          style: V2ShellVisual.sectionLabel(theme),
        ),
        const SizedBox(height: AppDesignConstants.v2GapControl),
        for (final feature in _features(loc))
          _FeatureRow(label: feature),
      ],
    );
  }

  static List<String> _features(AppLocalizations loc) => [
        loc.v2PremiumFeatureNoAds,
        loc.v2PremiumFeatureBiometric,
        loc.v2PremiumFeatureCloudSync,
        loc.v2PremiumFeatureStealth,
        loc.v2PremiumFeatureFullStats,
        loc.v2PremiumFeatureWeeklyArchive,
        loc.v2PremiumIncludeChart,
        loc.v2PremiumIncludeThemes,
      ];
}

enum PremiumPlanChoice { monthly, annual }

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.highlighted,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? (highlighted ? AppColors.goldText : AppColors.primary)
        : AppColors.border;
    final bg = highlighted
        ? AppColors.goldDim.withValues(alpha: 0.35)
        : AppColors.card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: highlighted ? AppColors.goldText : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: highlighted
                                  ? AppColors.goldText
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: V2ShellVisual.goldTagDecoration(),
                            child: Text(
                              badge!,
                              style: V2ShellVisual.goldTagLabel(theme),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: V2ShellVisual.captionMuted(theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
