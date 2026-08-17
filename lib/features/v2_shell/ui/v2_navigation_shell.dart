import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../domain/v2_shell_tab.dart';

/// NAV-SHELL — canonical four-tab V2 composition (Slice 9.1A).
///
/// Tabs: Today · Program · Progress · Profile.
/// Brain Check and Reports remain contextual routes outside this bar.
///
/// Navigation only: does not mutate Score, Plan, Progress, Reports, or Sessions.
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.55),
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: AppDesignConstants.v2NavHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.22),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return theme.textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.15,
                fontSize: selected ? 12.5 : 12,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: selected ? 24 : 22,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: index,
            backgroundColor: Colors.transparent,
            onDestinationSelected: (i) {
              navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today),
                label: loc.v2NavToday,
                tooltip: loc.v2NavToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: loc.v2NavPlan,
                tooltip: loc.v2NavPlan,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights),
                label: loc.v2NavProgress,
                tooltip: loc.v2NavProgress,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: loc.v2NavProfile,
                tooltip: loc.v2NavProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
