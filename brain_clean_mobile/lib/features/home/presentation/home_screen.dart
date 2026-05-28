import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import 'widgets/global_progress_tracker.dart';

const homeDiagnosticTileKey = Key('home_diagnostic_tile');
const homeCognitiveHubTileKey = Key('home_cognitive_hub_tile');
const homeRecoveryTileKey = Key('home_recovery_tile');
const homeDetoxTileKey = Key('home_detox_tile');

/// Definitive app entry after splash hydration.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(bcScoreSessionProvider);
    final recoveryAsync = ref.watch(recoveryProtocolControllerProvider);

    final bcScore = session?.bcScore ?? 0;
    final challengeProgress = recoveryAsync.maybeWhen(
      data: (state) => state.progressRatio,
      orElse: () => 0.0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(loc.homeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlobalProgressTracker(
              bcScore: bcScore,
              challengeProgress: challengeProgress,
              hasSession: session != null,
            ),
            if (session != null) ...[
              const SizedBox(height: 16),
              BcScoreBreakdown.fromSession(session: session),
            ] else ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    loc.homeEmptyDiagnosticPrompt,
                    textAlign: TextAlign.center,
                    style: context.arabicBodyStyle.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _NavTile(
              key: homeDiagnosticTileKey,
              icon: Icons.analytics_outlined,
              title: loc.homeOpenDiagnostic,
              subtitle: loc.homeOpenDiagnosticSubtitle,
              onTap: () => context.push(AppRoutes.diagnostic),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeCognitiveHubTileKey,
              icon: Icons.visibility_outlined,
              title: loc.homeOpenCognitiveHub,
              subtitle: loc.homeOpenCognitiveHubSubtitle,
              onTap: () => context.push(AppRoutes.cognitiveHub),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeRecoveryTileKey,
              icon: Icons.grid_view_rounded,
              title: loc.dashboardOpenRecoveryGrid,
              subtitle: loc.dashboardOpenRecoveryGridSubtitle,
              onTap: () => context.push(AppRoutes.recovery),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeDetoxTileKey,
              icon: Icons.spa_outlined,
              title: loc.dashboardOpenDetoxCheckIn,
              subtitle: loc.dashboardOpenDetoxCheckInSubtitle,
              onTap: () => context.push(AppRoutes.detox),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.dashboard),
              child: Text(loc.homeOpenFullDashboard),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    super.key,
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
