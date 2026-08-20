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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final index =
        navigationShell.currentIndex.clamp(0, V2ShellTab.values.length - 1);
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final inactive = palette.textSecondary.withValues(alpha: 0.92);

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
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: AppDesignConstants.v2NavHeight,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.14),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return theme.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.primary : inactive,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1.15,
                  fontSize: 11,
                  letterSpacing: 0.1,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: selected ? 26 : 24,
                  color: selected ? AppColors.primary : inactive,
                  opacity: 1,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: index,
              backgroundColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) {
                navigationShell.goBranch(
                  i,
                  initialLocation: i == navigationShell.currentIndex,
                );
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded, color: inactive, size: 24),
                  selectedIcon: const Icon(
                    Icons.home_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  label: loc.v2NavHome,
                  tooltip: loc.v2NavHome,
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center_rounded,
                      color: inactive, size: 24),
                  selectedIcon: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  label: loc.v2NavExercises,
                  tooltip: loc.v2NavExercises,
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded,
                      color: inactive, size: 24),
                  selectedIcon: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  label: loc.v2NavProgress,
                  tooltip: loc.v2NavProgress,
                ),
                NavigationDestination(
                  icon: Icon(Icons.workspace_premium_rounded,
                      color: inactive, size: 24),
                  selectedIcon: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  label: loc.v2NavPro,
                  tooltip: loc.v2NavPro,
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded, color: inactive, size: 24),
                  selectedIcon: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  label: loc.v2NavProfile,
                  tooltip: loc.v2NavProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
