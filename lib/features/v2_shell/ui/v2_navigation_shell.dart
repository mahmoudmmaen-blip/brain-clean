import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/v2_shell_tab.dart';

/// NAV-SHELL — canonical four-tab V2 composition (Slice 9.1A).
///
/// Tabs: Today · Plan · Progress · Profile.
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
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
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
    );
  }
}
