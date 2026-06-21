import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/presentation/async_state_views.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../home/presentation/home_streak_provider.dart';
import '../../core/presentation/language_toggle_button.dart';
import '../gamification/level_progress_widget.dart';
import '../share/share_card_generator.dart';
import 'application/profile_emotions_provider.dart';

const profileStatsRowKey = Key('profile_stats_row');
const profileBadgeStreak7Key = Key('profile_badge_streak_7');
const profileEmptyEmotionsKey = Key('profile_empty_emotions');
const profileNameFieldKey = Key('profile_name_field');

/// User profile — stats, recent emotions, achievement badges.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _displayName(AppLocalizations loc, AppPreferencesState prefs) {
    final stored = prefs.profileDisplayName.trim();
    return stored.isEmpty ? loc.profileDefaultName : stored;
  }

  Future<void> _saveName() async {
    await ref
        .read(appPreferencesProvider.notifier)
        .setProfileDisplayName(_nameController.text);
    if (mounted) setState(() => _editingName = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final streakDays = ref.watch(homeStreakSnapshotProvider).days;
    final bcScore =
        (ref.watch(bcScoreSessionProvider)?.bcScore ?? 0.0).clamp(0.0, 100.0);
    final emotionsAsync = ref.watch(profileEmotionsProvider);
    final displayName = _displayName(loc, prefs);

    if (!_editingName && _nameController.text != displayName) {
      _nameController.text = displayName;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(displayName, style: const TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        actions: const [LanguageToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderSection(
            displayName: displayName,
            isPro: prefs.isProUser,
            proBadgeLabel: loc.profileProBadge,
            editingName: _editingName,
            nameController: _nameController,
            onTapName: () => setState(() => _editingName = true),
            onSaveName: _saveName,
          ),
          const SizedBox(height: 20),
          Row(
            key: profileStatsRowKey,
            children: [
              Expanded(
                child: _StatCard(
                  value: '$streakDays',
                  label: loc.profileStatFocusDays,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: '${bcScore.round()}',
                  label: loc.profileStatBcs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: '${emotionsAsync.maybeWhen(data: (d) => d.count, orElse: () => 0)}',
                  label: loc.profileStatEmotions,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LevelProgressWidget(),
          const SizedBox(height: 16),
          const ShareButton(),
          const ShareCardCapture(),
          const SizedBox(height: 24),
          Text(
            loc.profileRecentEmotions,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          emotionsAsync.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => AsyncStateViews.error(context),
            data: (emotions) {
              if (emotions.recent.isEmpty) {
                return Text(
                  loc.profileNoEmotionsYet,
                  key: profileEmptyEmotionsKey,
                  style: const TextStyle(color: AppColors.textSecondary),
                );
              }
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: emotions.recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final entry = emotions.recent[i];
                    return Chip(
                      label: Text(entry.label),
                      backgroundColor: AppColors.card,
                      labelStyle: const TextStyle(color: AppColors.textPrimary),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            loc.profileAchievements,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _BadgeCard(
                key: profileBadgeStreak7Key,
                emoji: '🔥',
                label: loc.profileBadgeStreak7,
                unlocked: streakDays >= 7,
              ),
              _BadgeCard(
                emoji: '🧠',
                label: loc.profileBadgeCleanBrain,
                unlocked: bcScore >= 80,
              ),
              _BadgeCard(
                emoji: '🏆',
                label: loc.profileBadgeSilenceHero,
                unlocked: prefs.silenceWinsCount >= 1,
              ),
              _BadgeCard(
                emoji: '⚡',
                label: loc.profileBadgeSingleTask,
                unlocked: prefs.singleTasksCompletedCount >= 1,
              ),
              _BadgeCard(
                emoji: '💚',
                label: loc.profileBadgeEmotionAwake,
                unlocked: emotionsAsync.maybeWhen(
                  data: (d) => d.count >= 5,
                  orElse: () => false,
                ),
              ),
              _BadgeCard(
                emoji: '🌟',
                label: loc.profileBadgeProMember,
                unlocked: prefs.isProUser,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.displayName,
    required this.isPro,
    required this.proBadgeLabel,
    required this.editingName,
    required this.nameController,
    required this.onTapName,
    required this.onSaveName,
  });

  final String displayName;
  final bool isPro;
  final String proBadgeLabel;
  final bool editingName;
  final TextEditingController nameController;
  final VoidCallback onTapName;
  final VoidCallback onSaveName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFF1D9E75),
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        if (editingName)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              key: profileNameFieldKey,
              controller: nameController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6EDF3),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSaveName(),
            ),
          )
        else
          GestureDetector(
            onTap: onTapName,
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE6EDF3),
              ),
            ),
          ),
        if (isPro) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              proBadgeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D9E75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.unlocked,
  });

  final String emoji;
  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF1D9E75).withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: unlocked ? 28 : 24)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: unlocked
                  ? const Color(0xFFE6EDF3)
                  : const Color(0xFF8B949E),
              fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );

    if (!unlocked) {
      return Opacity(
        opacity: 0.3,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: child,
        ),
      );
    }
    return child;
  }
}
