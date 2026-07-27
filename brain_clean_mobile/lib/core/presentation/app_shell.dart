import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/ad_visibility.dart';
import '../ads/footer_banner_ad.dart';
import '../constants/app_routes.dart';
import '../l10n/app_localizations.dart';
import '../../features/focus/widgets/ambient_sound_widgets.dart';
import '../../features/pro/application/subscription_service_provider.dart';

/// Persistent 5-tab shell with glass bottom navigation and calm support FAB.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const Color _supportFabBg = Color(0xFF1A3D3A);
  static const Color _supportFabFg = Color(0xFF5EEAD4);

  /// Extra FAB lift when a loaded footer banner sits below the nav.
  static const double _fabBannerClearance = 16;

  bool _bannerVisible = false;

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onBannerVisibilityChanged(bool visible) {
    if (!mounted || _bannerVisible == visible) return;
    setState(() => _bannerVisible = visible);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final path = GoRouterState.of(context).uri.path;
    final showSupportFab = path != AppRoutes.proPaywall;
    final isPro = ref.watch(isProUserProvider);
    final showAds = AdVisibility.shouldShowFooterBanner(
      isPro: isPro,
      location: path,
    );
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // Reset visibility tracking when ads are not allowed on this route.
    if (!showAds && _bannerVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _bannerVisible) {
          setState(() => _bannerVisible = false);
        }
      });
    }

    // Scaffold already lifts the FAB above the whole bottomNavigationBar.
    // Add a small extra clearance when the compact banner is loaded.
    final fabBottomPad = (_bannerVisible && showAds)
        ? FooterBannerAd.reservedStripHeight + _fabBannerClearance
        : 0.0;

    return Scaffold(
      // Body is inset by Scaffold for bottomNavigationBar height, so scrollable
      // shell content is not covered by nav or banner.
      body: widget.navigationShell,
      floatingActionButton: showSupportFab
          ? Padding(
              padding: EdgeInsets.only(bottom: fabBottomPad),
              child: FloatingActionButton(
                heroTag: 'sos_fab',
                backgroundColor: _supportFabBg,
                foregroundColor: _supportFabFg,
                elevation: 2,
                onPressed: () => context.push(AppRoutes.recovery),
                tooltip: loc.sosFabTooltip,
                child: const Icon(Icons.self_improvement_outlined),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AmbientMiniPlayer(),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: NavigationBar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
                indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
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
          // Banner sits below nav so it is less prominent than browsing chrome.
          if (showAds) ...[
            Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
            ColoredBox(
              color: colorScheme.surface.withValues(alpha: 0.92),
              child: FooterBannerAd(
                key: const Key('footer_banner_ad'),
                onVisibilityChanged: _onBannerVisibilityChanged,
              ),
            ),
          ],
          // Minimal system inset only (home indicator / gesture bar).
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
