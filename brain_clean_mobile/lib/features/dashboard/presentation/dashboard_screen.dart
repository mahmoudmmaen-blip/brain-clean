import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';
import '../../diagnostic/presentation/widgets/brain_rot_colors.dart';

/// Stable widget-test anchor for the detox check-in [ListTile].
const dashboardDetoxCheckInTileKey = Key('dashboard_detox_check_in_tile');
const dashboardRecoveryGridTileKey = Key('dashboard_recovery_grid_tile');

/// Pushes the 7-day detox check-in screen onto the navigation stack.
void _navigateToDetoxCheckIn(BuildContext context) {
  if (!context.mounted) return;
  context.push(AppRoutes.detox);
}

void _navigateToRecoveryGrid(BuildContext context) {
  if (!context.mounted) return;
  context.push(AppRoutes.recovery);
}

/// Replaces the stack with the diagnostic flow entry screen.
void _navigateToDiagnostic(BuildContext context) {
  context.go(AppRoutes.diagnostic);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
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
                  final evaluation = session.pillarEvaluation;
                  final scoreKey = ValueKey<int>(session.bcScore.round());
                  return Column(
                    children: [
                      RepaintBoundary(
                        child: BcScoreHeroCard(
                          key: scoreKey,
                          score: session.bcScore,
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
                      color: BrainRotColors.forBand(session.brainRot!.band),
                    ),
                  ),
                ),
              ],
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    loc.dashboardEmptyDiagnosticPrompt,
                    textAlign: TextAlign.center,
                    style: context.arabicBodyStyle.copyWith(color: context.textMuted),
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
