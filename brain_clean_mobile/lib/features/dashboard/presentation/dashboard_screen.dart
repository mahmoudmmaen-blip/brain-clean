import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';

/// Pushes the 7-day detox check-in screen onto the navigation stack.
void _navigateToDetoxCheckIn(BuildContext context) {
  context.push(AppRoutes.detox);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(bcScoreSessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.dashboardTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (session != null) ...[
              BcScoreHeroCard(
                score: session.bcScore,
                fontSize: 48,
                subtitle:
                    'Committed ${session.committedAt.toLocal().toString().substring(0, 16)}',
              ),
              BcScoreBreakdown(model: session.model),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    loc.dashboardEmptyDiagnosticPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('dashboard_detox_check_in_tile'),
                title: Text(loc.dashboardOpenDetoxCheckIn),
                subtitle: Text(loc.dashboardOpenDetoxCheckInSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDetoxCheckIn(context),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.diagnostic),
              child: Text(loc.dashboardRetakeDiagnostic),
            ),
          ],
        ),
      ),
    );
  }
}
