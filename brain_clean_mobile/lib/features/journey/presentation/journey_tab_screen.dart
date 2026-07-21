import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../anxiety/presentation/anxiety_latest_result_provider.dart';
import '../../bci/presentation/widgets/bci_card.dart';
import '../../dashboard/presentation/pro_gated_seven_day_chart.dart';
import 'widgets/safa_night_journal_checkin_card.dart';

/// Journey tab — live BCI hero, 7-day chart, then secondary quick links.
class JourneyTabScreen extends ConsumerWidget {
  const JourneyTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final latestAnxiety = ref.watch(anxietyLatestResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.journeyTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            button: true,
            label: loc.bciCardTitle,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push(AppRoutes.dashboard),
                child: const BciCard(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const ProGatedSevenDayChart(),
          const SizedBox(height: 4),
          const SafaNightJournalCheckinCard(),
          const SizedBox(height: 8),
          Text(
            loc.journeyQuickLinksTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          _JourneyQuickLink(
            icon: Icons.analytics_outlined,
            title: loc.journeyCardDiagnosticTitle,
            onTap: () => context.push(AppRoutes.diagnostic),
          ),
          _JourneyQuickLink(
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
          _JourneyQuickLink(
            icon: Icons.calendar_view_week_outlined,
            title: loc.journeyCardWeeklyReportTitle,
            onTap: () => context.push(AppRoutes.weeklyReport),
          ),
        ],
      ),
    );
  }
}

class _JourneyQuickLink extends StatelessWidget {
  const _JourneyQuickLink({
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
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Icon(icon, size: 22, color: colorScheme.primary),
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
          trailing: Icon(
            Icons.chevron_right,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
