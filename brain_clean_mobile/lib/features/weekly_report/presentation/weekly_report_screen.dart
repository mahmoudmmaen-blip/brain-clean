import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/metric_info_row.dart';
import '../application/weekly_report_provider.dart';
import '../domain/weekly_report_data.dart';
import '../domain/weekly_report_service.dart';

const weeklyReportScreenKey = Key('weekly_report_screen');
const weeklyReportCoralNegative = Color(0xFFFF5A5F);

/// Weekly progress summary — opened from Journey tab or notification.
class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(weeklyReportProvider);

    return Scaffold(
      key: weeklyReportScreenKey,
      appBar: AppBar(
        title: Text(loc.weeklyReportTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(loc.weeklyReportLoadError)),
        data: (report) => _WeeklyReportBody(report: report),
      ),
    );
  }
}

class _WeeklyReportBody extends ConsumerWidget {
  const _WeeklyReportBody({required this.report});

  final WeeklyReportData report;

  String _dateRangeLabel(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).toString();
    final formatter = DateFormat.MMMd(locale);
    final start = formatter.format(report.weekStart);
    final end = formatter.format(report.weekEnd);
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _dateRangeLabel(context, ref),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report.motivationalMessage,
          key: const Key('weekly_report_message'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        _BciCard(report: report),
        const SizedBox(height: 12),
        _ActivitySummaryCard(report: report),
        if (report.bestGameName != null) ...[
          const SizedBox(height: 12),
          _BestGameCard(gameName: report.bestGameName!),
        ],
        if (report.anxietyScore != null) ...[
          const SizedBox(height: 12),
          _AnxietyCard(anxietyScore: report.anxietyScore!),
        ],
        const SizedBox(height: 12),
        _SafaMessageCard(
          message: WeeklyReportService.safaMessageForWorryCount(
            report.worryEntriesCount,
            isArabic: isArabic,
          ),
        ),
      ],
    );
  }
}

class _BciCard extends StatelessWidget {
  const _BciCard({required this.report});

  final WeeklyReportData report;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.weeklyReportBciLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (!report.hasBciData)
            Text(
              loc.weeklyReportBciNoData,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else ...[
            Text(
              '${report.avgBciScore.toStringAsFixed(1)}%',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _BciChangeIndicator(change: report.bciChange),
          ],
        ],
      ),
    );
  }
}

class _BciChangeIndicator extends StatelessWidget {
  const _BciChangeIndicator({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (change > 0) {
      return Text(
        loc.weeklyReportBciUp(change.toStringAsFixed(1)),
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (change < 0) {
      return Text(
        loc.weeklyReportBciDown(change.abs().toStringAsFixed(1)),
        style: const TextStyle(
          color: weeklyReportCoralNegative,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(
      loc.weeklyReportBciFlat,
      style: TextStyle(
        color: colorScheme.tertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard({required this.report});

  final WeeklyReportData report;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.weeklyReportActivityTitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: loc.weeklyReportStatGamesIcon,
                  value: '${report.gamesPlayed}',
                  label: loc.weeklyReportStatGames,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: loc.weeklyReportStatChallengesIcon,
                  value: loc.weeklyReportStatChallengesValue(
                    report.dailyChallengesCompleted,
                  ),
                  label: loc.weeklyReportStatChallenges,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: loc.weeklyReportStatWorryIcon,
                  value: '${report.worryEntriesCount}',
                  label: loc.weeklyReportStatWorry,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: loc.weeklyReportStatStreakIcon,
                  value: '${report.streakDays}',
                  label: loc.weeklyReportStatStreak,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _BestGameCard extends StatelessWidget {
  const _BestGameCard({required this.gameName});

  final String gameName;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        children: [
          Text(
            loc.weeklyReportBestGameTitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gameName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.weeklyReportBestGameSubtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AnxietyCard extends StatelessWidget {
  const _AnxietyCard({required this.anxietyScore});

  final double anxietyScore;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final calmIndex = (100 - anxietyScore).clamp(0, 100);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.weeklyReportCalmTitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          MetricInfoRow(
            oneLiner: loc.calmIndexOneLiner,
            fullExplanation: loc.calmIndexFullExplanation,
            sheetTitle: loc.weeklyReportCalmTitle,
            compact: true,
          ),
          const SizedBox(height: 12),
          Text(
            '${calmIndex.toStringAsFixed(0)}%',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: calmIndex / 100,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafaMessageCard extends StatelessWidget {
  const _SafaMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              loc.weeklyReportSafaAvatar,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
