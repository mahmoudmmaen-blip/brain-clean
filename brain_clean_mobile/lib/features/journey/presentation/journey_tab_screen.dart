import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../anxiety/presentation/anxiety_latest_result_provider.dart';

/// Journey tab — BCI dashboard, diagnostic, and weekly report entry points.
class JourneyTabScreen extends ConsumerWidget {
  const JourneyTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final latestAnxiety = ref.watch(anxietyLatestResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.journeyTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _JourneyCard(
            icon: Icons.insights_outlined,
            title: loc.journeyCardBciTitle,
            onTap: () => context.push(AppRoutes.dashboard),
          ),
          _JourneyCard(
            icon: Icons.analytics_outlined,
            title: loc.journeyCardDiagnosticTitle,
            onTap: () => context.push(AppRoutes.diagnostic),
          ),
          _JourneyCard(
            icon: Icons.psychology_alt_outlined,
            title: loc.anxietyJourneyCardTitle,
            subtitle: latestAnxiety.maybeWhen(
              data: (result) => result == null
                  ? loc.anxietyJourneyCardSubtitle
                  : loc.anxietyJourneyCardLatestScore(result.score.round()),
              orElse: () => loc.anxietyJourneyCardSubtitle,
            ),
            onTap: () => context.push(AppRoutes.anxietyDiagnostic),
          ),
          _JourneyCard(
            icon: Icons.calendar_view_week_outlined,
            title: loc.journeyCardWeeklyReportTitle,
            onTap: () => context.push(AppRoutes.weeklyReport),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
