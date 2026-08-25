import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';

/// Phase 5 Tests catalog — IQ, digital brain rot, cognitive, weekly check.
class TestsCatalogScreen extends StatelessWidget {
  const TestsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(loc.testsCatalogTitle)),
      body: ListView(
        padding: V2ShellVisual.pagePadding(top: 8),
        children: [
          Text(
            loc.testsCatalogSubtitle,
            style: V2ShellVisual.bodyMuted(theme),
          ),
          const SizedBox(height: AppDesignConstants.v2GapSection),
          _TestTile(
            icon: Icons.psychology_alt_outlined,
            title: loc.briTestTitle,
            subtitle: loc.briTestSubtitle,
            onTap: () => context.push(AppRoutes.v2BriTest),
          ),
          _TestTile(
            icon: Icons.psychology_outlined,
            title: loc.iqTestTitle,
            subtitle: loc.iqTestSubtitle,
            onTap: () => context.push(AppRoutes.v2IqTest),
          ),
          _TestTile(
            icon: Icons.smartphone_outlined,
            title: loc.digitalBrainRotTestTitle,
            subtitle: loc.digitalBrainRotTestSubtitle,
            onTap: () => context.push(AppRoutes.v2DigitalBrainRotTest),
          ),
          _TestTile(
            icon: Icons.visibility_outlined,
            title: loc.cognitiveVisualTestTitle,
            subtitle: loc.cognitiveVisualTestSubtitle,
            onTap: () => context.push(AppRoutes.cognitiveVisual),
          ),
          _TestTile(
            icon: Icons.memory_outlined,
            title: loc.cognitiveMemoryGameTitle,
            subtitle: loc.cognitiveMemoryGameSubtitle,
            onTap: () => context.push(AppRoutes.cognitiveMemory),
          ),
          _TestTile(
            icon: Icons.quiz_outlined,
            title: loc.diagFlowTitle,
            subtitle: loc.diagIntroBody,
            onTap: () => context.push(AppRoutes.v2InteractiveDiagnostic),
          ),
          _TestTile(
            icon: Icons.calendar_view_week_outlined,
            title: loc.homeWeeklyTestTitle,
            subtitle: loc.homeWeeklyTestReady,
            onTap: () => context.go(
              V2SetupRecovery.brainCheckLocation(source: 'weekly'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDesignConstants.minTouchTarget,
            ),
            child: ListTile(
              leading: Icon(icon, color: AppColors.primary),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              subtitle: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
