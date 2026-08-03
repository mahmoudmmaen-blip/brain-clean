import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/v2_shell_tab.dart';

/// NAV-SHELL — six-tab V2 composition over existing screens (Slice 9.1).
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
    final index = navigationShell.currentIndex.clamp(0, V2ShellTab.values.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: AppColors.background,
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
            label: loc.v2NavCheck,
            tooltip: loc.v2NavCheck,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: loc.v2NavPlan,
            tooltip: loc.v2NavPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: loc.v2NavProgress,
            tooltip: loc.v2NavProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: loc.v2NavReports,
            tooltip: loc.v2NavReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: loc.v2NavProfile,
            tooltip: loc.v2NavProfile,
          ),
        ],
      ),
    );
  }
}
