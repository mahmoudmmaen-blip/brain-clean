import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/language_toggle_button.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../profile/application/profile_emotions_provider.dart';
import '../dashboard/data/daily_snapshots_repository.dart';
import '../home/presentation/home_streak_provider.dart';
import '../reports/weekly_report_logic.dart';
import '../share/share_card_generator.dart';

const weeklyReportScreenKey = Key('weekly_report_screen');

/// Weekly progress summary — opened from notification or profile.
class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  static int _streakDaysThisWeek(List<DateTime> activeDays) =>
      activeDays.length.clamp(0, 7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final streakDays = ref.watch(homeStreakSnapshotProvider).days;
    final bcs =
        (ref.watch(bcScoreSessionProvider)?.bcScore ?? 0).clamp(0.0, 100.0);

    List<double> weekBcs = const [];
    String bestEmotion = isArabic ? '—' : '—';
    var challengesCompleted = 0;

    try {
      final snapshots = ref.watch(dailySnapshotsRepositoryProvider).loadAll();
      if (snapshots.isNotEmpty) {
        weekBcs = snapshots.length > 7
            ? snapshots.sublist(snapshots.length - 7).map((s) => s.bcsValue).toList()
            : snapshots.map((s) => s.bcsValue).toList();
      }
    } catch (_) {}

    final emotions = ref.watch(profileEmotionsProvider).maybeWhen(
          data: (d) => d.recent,
          orElse: () => const [],
        );
    if (emotions.isNotEmpty) {
      bestEmotion = emotions.first.label;
    }

    challengesCompleted = streakDays.clamp(0, 7);
    final avgBcs = weekBcs.isEmpty
        ? bcs
        : weekBcs.reduce((a, b) => a + b) / weekBcs.length;
    final message = weeklyReportMessage(
      streakDaysThisWeek: streakDays.clamp(0, 7),
      isArabic: isArabic,
    );

    return Scaffold(
      key: weeklyReportScreenKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(loc.weeklyReportTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            message,
            key: Key('weekly_report_message'),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            loc.weeklyReportStreakDays,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final active = i < streakDays.clamp(0, 7);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 12,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          _StatTile(
            label: loc.weeklyReportAvgBcs,
            value: avgBcs.toStringAsFixed(0),
          ),
          _StatTile(label: loc.weeklyReportBestEmotion, value: bestEmotion),
          _StatTile(
            label: loc.weeklyReportChallenges,
            value: '$challengesCompleted',
          ),
          const SizedBox(height: 24),
          const ShareButton(),
          const SizedBox(height: 8),
          const ShareCardCapture(),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
