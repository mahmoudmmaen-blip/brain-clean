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

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (index == 0) return false;
        navigationShell.goBranch(0);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: AppDesignConstants.v2NavHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return theme.textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.15,
                fontSize: 10.5,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: selected ? 22 : 20,
                color: selected ? AppColors.primary : AppColors.textTertiary,
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
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: loc.v2NavHome,
                tooltip: loc.v2NavHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.psychology_outlined),
                selectedIcon: const Icon(Icons.psychology),
                label: loc.v2NavExercises,
                tooltip: loc.v2NavExercises,
              ),
              NavigationDestination(
                icon: const Icon(Icons.show_chart_outlined),
                selectedIcon: const Icon(Icons.show_chart),
                label: loc.v2NavProgress,
                tooltip: loc.v2NavProgress,
              ),
              NavigationDestination(
                icon: const Icon(Icons.workspace_premium_outlined),
                selectedIcon: const Icon(Icons.workspace_premium),
                label: loc.v2NavPro,
                tooltip: loc.v2NavPro,
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
    ),
    );
  }
}
