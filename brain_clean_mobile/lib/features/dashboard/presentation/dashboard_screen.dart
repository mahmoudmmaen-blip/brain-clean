import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';
import '../../diagnostic/presentation/widgets/brain_rot_colors.dart';

/// Stable widget-test anchor for the detox check-in [ListTile].
const dashboardDetoxCheckInTileKey = Key('dashboard_detox_check_in_tile');
const dashboardRecoveryGridTileKey = Key('dashboard_recovery_grid_tile');

void _navigateToDetoxCheckIn(BuildContext context) {
  if (!context.mounted) return;
  context.push(AppRoutes.detox);
}

void _navigateToRecoveryGrid(BuildContext context) {
  if (!context.mounted) return;
  context.push(AppRoutes.recovery);
}

void _navigateToDiagnostic(BuildContext context) {
  context.push(AppRoutes.diagnostic);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final session = ref.watch(bcScoreSessionProvider);
    final committedAt = session == null
        ? null
        : session.committedAt.toLocal().toString().substring(0, 16);

    return Scaffold(
      appBar: AppBar(title: Text(loc.dashboardTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (session != null) ...[
              Builder(
                builder: (context) {
                  final scoreKey = ValueKey<int>(session.bcScore.round());
                  return Column(
                    children: [
                      RepaintBoundary(
                        child: BcScoreHeroCard.fromSession(
                          key: scoreKey,
                          session: session,
                          fontSize: 48,
                          subtitle: loc.dashboardCommittedAt(committedAt!),
                        ),
                      ),
                      RepaintBoundary(
                        child: BcScoreBreakdown.fromSession(
                          key: ValueKey<String>('dash_breakdown_$scoreKey'),
                          session: session,
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (session.brainRot != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: Text(
                      loc.dashboardBrainRotSummary(session.brainRot!.score),
                    ),
                    subtitle: Text(session.brainRot!.interpretationAr),
                    leading: Icon(
                      Icons.psychology_outlined,
                      color: BrainRotColors.forBand(
                        session.brainRot!.band,
                        Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
                ),
              ],
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        loc.dashboardEmptyTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        loc.dashboardEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _navigateToDiagnostic(context),
                        child: Text(loc.dashboardEmptyCta),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: dashboardDetoxCheckInTileKey,
                title: Text(loc.dashboardOpenDetoxCheckIn),
                subtitle: Text(loc.dashboardOpenDetoxCheckInSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDetoxCheckIn(context),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: dashboardRecoveryGridTileKey,
                title: Text(loc.dashboardOpenRecoveryGrid),
                subtitle: Text(loc.dashboardOpenRecoveryGridSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToRecoveryGrid(context),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _navigateToDiagnostic(context),
              child: Text(loc.dashboardRetakeDiagnostic),
            ),
          ],
        ),
      ),
    );
  }
}
