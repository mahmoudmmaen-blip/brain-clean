import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../security/security_warning_banner.dart';
import '../../features/focus/widgets/ambient_sound_widgets.dart';

/// Persistent 5-tab shell with glass bottom navigation and SOS FAB.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SafeArea(
            bottom: false,
            child: SecurityWarningBanner(),
          ),
          Expanded(child: widget.navigationShell),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sos_fab',
        backgroundColor: const Color(0xFFFF5A5F),
        onPressed: () => context.push(AppRoutes.recovery),
        tooltip: loc.sosFabTooltip,
        child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AmbientMiniPlayer(),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: NavigationBar(
                backgroundColor: colorScheme.surface.withOpacity(0.85),
                indicatorColor: colorScheme.primary.withOpacity(0.15),
                selectedIndex: widget.navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: loc.navTabHome,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.self_improvement_outlined),
                    selectedIcon: const Icon(Icons.self_improvement),
                    label: loc.navTabExercises,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.smart_toy_outlined),
                    selectedIcon: const Icon(Icons.smart_toy),
                    label: loc.navTabSafa,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.timeline_outlined),
                    selectedIcon: const Icon(Icons.timeline),
                    label: loc.navTabJourney,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.more_horiz_outlined),
                    selectedIcon: const Icon(Icons.more_horiz),
                    label: loc.navTabMore,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
