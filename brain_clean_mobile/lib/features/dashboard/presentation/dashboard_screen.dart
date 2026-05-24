import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bcScoreSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Brain Clean Dashboard')),
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
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Complete the diagnostic to see your BC_score.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.diagnostic),
              child: const Text('Retake Diagnostic'),
            ),
          ],
        ),
      ),
    );
  }
}
