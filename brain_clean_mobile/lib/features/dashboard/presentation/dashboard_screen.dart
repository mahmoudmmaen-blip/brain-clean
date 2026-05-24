import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'BRAIN CLARITY SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${session.bcScoreRounded}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: _scoreColor(session.bcScore),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Committed ${session.committedAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
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

  static Color _scoreColor(double score) {
    if (score <= 30) return const Color(0xFFEF4444);
    if (score <= 60) return AppTheme.gold;
    if (score <= 85) return AppTheme.success;
    return const Color(0xFF0F6E56);
  }
}
