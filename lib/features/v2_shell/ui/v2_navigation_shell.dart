import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../domain/v2_shell_tab.dart';

/// NAV-SHELL — Pro mock five-tab composition.
///
/// Tabs: Home · Exercises · Progress · Pro · Profile.
class V2NavigationShell extends StatelessWidget {
  const V2NavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (Icons.home_rounded, 'home'),
    (Icons.fitness_center_rounded, 'exercises'),
    (Icons.bar_chart_rounded, 'progress'),
    (Icons.workspace_premium_rounded, 'pro'),
    (Icons.person_rounded, 'profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final index =
        navigationShell.currentIndex.clamp(0, V2ShellTab.values.length - 1);
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final inactive = palette.textSecondary.withValues(alpha: 0.92);
    final labels = [
      loc.v2NavHome,
      loc.v2NavExercises,
      loc.v2NavProgress,
      loc.v2NavPro,
      loc.v2NavProfile,
    ];

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (index == 0) return false;
        navigationShell.goBranch(0);
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.navBar,
            border: Border(
              top: BorderSide(color: palette.border, width: 1.2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: AppDesignConstants.v2NavHeight,
              child: Row(
                children: [
                  for (var i = 0; i < _destinations.length; i++)
                    _V2NavTab(
                      icon: _destinations[i].$1,
                      label: labels[i],
                      selected: i == index,
                      inactiveColor: inactive,
                      onTap: () {
                        navigationShell.goBranch(
                          i,
                          initialLocation: i == navigationShell.currentIndex,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _V2NavTab extends StatelessWidget {
  const _V2NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? AppColors.primary : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: selected ? 28 : 26, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1.1,
                  fontSize: 11,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 3,
                width: selected ? 28 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
