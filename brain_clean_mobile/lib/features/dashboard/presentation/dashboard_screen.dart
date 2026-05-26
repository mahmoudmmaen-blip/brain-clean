import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openDetoxCheckIn(BuildContext context) {
    context.push(AppRoutes.detox);
  }

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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Icon(
                  Icons.spa_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  loc.dashboardOpenDetoxCheckIn,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                subtitle: Text(
                  loc.dashboardOpenDetoxCheckInSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => _openDetoxCheckIn(context),
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
