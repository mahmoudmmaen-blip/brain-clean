import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../games/color_word_game.dart';
import '../../games/n_back_game.dart';
import '../../games/number_memory_game.dart';
import '../../games/pattern_logic_game.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../domain/exercise_library.dart';

/// Exercise library tab — categories, icons, time & difficulty badges.
class V2ExercisesLibraryScreen extends ConsumerStatefulWidget {
  const V2ExercisesLibraryScreen({super.key});

  @override
  ConsumerState<V2ExercisesLibraryScreen> createState() =>
      _V2ExercisesLibraryScreenState();
}

class _V2ExercisesLibraryScreenState
    extends ConsumerState<V2ExercisesLibraryScreen> {
  ExerciseLibraryFilter _filter = ExerciseLibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPro = ref.watch(isProUserProvider);
    final filters = [
      (ExerciseLibraryFilter.all, loc.v2ExercisesFilterAll),
      (ExerciseLibraryFilter.memory, loc.v2ExercisesFilterMemory),
      (ExerciseLibraryFilter.intelligence, loc.v2ExercisesFilterIntelligence),
      (ExerciseLibraryFilter.focus, loc.v2ExercisesFilterFocus),
      (ExerciseLibraryFilter.speed, loc.v2ExercisesFilterSpeed),
    ];
    final freeItems = ExerciseLibraryCatalog.forTierAndFilter(
      ExerciseLibraryTier.free,
      _filter,
    );
    final proItems = ExerciseLibraryCatalog.forTierAndFilter(
      ExerciseLibraryTier.pro,
      _filter,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: V2ShellVisual.pagePadding(),
          children: [
            V2PageHeader(title: loc.v2ExercisesLibraryTitle),
            const SizedBox(height: AppDesignConstants.v2GapControl),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < filters.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _FilterPill(
                      label: filters[i].$2,
                      selected: _filter == filters[i].$1,
                      onTap: () => setState(() => _filter = filters[i].$1),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDesignConstants.v2GapSection),
            if (freeItems.isNotEmpty) ...[
              _SectionHeader(label: loc.v2ExercisesSectionFree),
              const SizedBox(height: AppDesignConstants.v2GapControl),
              for (final item in freeItems)
                _ExerciseCard(
                  icon: item.icon,
                  iconBg: item.iconBg,
                  iconColor: item.iconColor,
                  title: _titleFor(item, loc),
                  subtitle: _subtitleFor(item, loc),
                  timeLabel: loc.v2ExercisesMinutes(item.estimatedMinutes),
                  difficultyLabel: _difficultyLabel(item.difficulty, loc),
                  difficulty: item.difficulty,
                  locked: false,
                  showProBadge: false,
                  scienceBadgeLabel: _scienceBadgeFor(item, loc),
                  onTap: () => _openExercise(context, item, isPro),
                ),
              const SizedBox(height: AppDesignConstants.v2GapSection),
            ],
            if (proItems.isNotEmpty) ...[
              _SectionHeader(label: loc.v2ExercisesSectionPro),
              const SizedBox(height: AppDesignConstants.v2GapControl),
              for (final item in proItems)
                _ExerciseCard(
                  icon: item.icon,
                  iconBg: item.iconBg,
                  iconColor: item.iconColor,
                  title: _titleFor(item, loc),
                  subtitle: _subtitleFor(item, loc),
                  timeLabel: loc.v2ExercisesMinutes(item.estimatedMinutes),
                  difficultyLabel: _difficultyLabel(item.difficulty, loc),
                  difficulty: item.difficulty,
                  locked: !isPro,
                  showProBadge: true,
                  proBadgeLabel: loc.v2ExercisesProBadge,
                  scienceBadgeLabel: _scienceBadgeFor(item, loc),
                  onTap: () => _openExercise(context, item, isPro),
                ),
            ],
            if (freeItems.isEmpty && proItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  loc.v2ExercisesEmptyFilter,
                  style: V2ShellVisual.bodyMuted(theme),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(
    ExerciseLibraryDifficulty difficulty,
    AppLocalizations loc,
  ) {
    return switch (difficulty) {
      ExerciseLibraryDifficulty.easy => loc.v2ExercisesDifficultyEasy,
      ExerciseLibraryDifficulty.medium => loc.v2ExercisesDifficultyMedium,
      ExerciseLibraryDifficulty.hard => loc.v2ExercisesDifficultyHard,
    };
  }

  String _titleFor(ExerciseLibraryItem item, AppLocalizations loc) {
    return switch (item.titleKey) {
      'v2ExercisesNBackTitle' => loc.v2ExercisesNBackTitle,
      'v2ExercisesStroopTitle' => loc.v2ExercisesStroopTitle,
      'v2ExercisesDigitSpanTitle' => loc.v2ExercisesDigitSpanTitle,
      'v2ExercisesGoNoGoTitle' => loc.v2ExercisesGoNoGoTitle,
      'v2ExercisesReadingComprehensionTitle' =>
        loc.v2ExercisesReadingComprehensionTitle,
      'v2ExercisesHiitTitle' => loc.v2ExercisesHiitTitle,
      'v2ExercisesPatternLogicTitle' => loc.v2ExercisesPatternLogicTitle,
      _ => item.titleKey,
    };
  }

  String _subtitleFor(ExerciseLibraryItem item, AppLocalizations loc) {
    return switch (item.subtitleKey) {
      'v2ExercisesNBackSubtitle' => loc.v2ExercisesNBackSubtitle,
      'v2ExercisesStroopSubtitle' => loc.v2ExercisesStroopSubtitle,
      'v2ExercisesDigitSpanSubtitle' => loc.v2ExercisesDigitSpanSubtitle,
      'v2ExercisesGoNoGoSubtitle' => loc.v2ExercisesGoNoGoSubtitle,
      'v2ExercisesReadingComprehensionSubtitle' =>
        loc.v2ExercisesReadingComprehensionSubtitle,
      'v2ExercisesHiitSubtitle' => loc.v2ExercisesHiitSubtitle,
      'v2ExercisesPatternLogicSubtitle' => loc.v2ExercisesPatternLogicSubtitle,
      _ => item.subtitleKey,
    };
  }

  String? _scienceBadgeFor(ExerciseLibraryItem item, AppLocalizations loc) {
    return switch (item.scienceBadgeKey) {
      'v2ExercisesScienceBadgeNBack' => loc.v2ExercisesScienceBadgeNBack,
      _ => null,
    };
  }

  void _openExercise(
    BuildContext context,
    ExerciseLibraryItem item,
    bool isPro,
  ) {
    if (item.tier == ExerciseLibraryTier.pro && !isPro) {
      context.push(AppRoutes.v2PremiumWithSource('exercise_library'));
      return;
    }

    switch (item.launch) {
      case ExerciseLibraryLaunch.nBack:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NBackGameScreen(),
          ),
        );
      case ExerciseLibraryLaunch.stroop:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ColorWordGameScreen(),
          ),
        );
      case ExerciseLibraryLaunch.digitSpan:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NumberMemoryGameScreen(),
          ),
        );
      case ExerciseLibraryLaunch.patternMatch:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PatternLogicGameScreen(),
          ),
        );
      case ExerciseLibraryLaunch.goNoGo:
      case ExerciseLibraryLaunch.focusedReading:
      case ExerciseLibraryLaunch.hiit:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsComingSoon),
          ),
        );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: V2ShellVisual.sectionLabel(Theme.of(context)),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: selected ? AppColors.primary : palette.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      selected ? AppColors.onPrimary : palette.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.difficultyLabel,
    required this.difficulty,
    required this.locked,
    required this.showProBadge,
    required this.onTap,
    this.proBadgeLabel,
    this.scienceBadgeLabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String difficultyLabel;
  final ExerciseLibraryDifficulty difficulty;
  final bool locked;
  final bool showProBadge;
  final String? proBadgeLabel;
  final String? scienceBadgeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.of(context);
    final dots = switch (difficulty) {
      ExerciseLibraryDifficulty.easy => 1,
      ExerciseLibraryDifficulty.medium => 2,
      ExerciseLibraryDifficulty.hard => 3,
    };
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        border: Border.all(
          color: locked ? AppColors.gold : palette.border,
          width: locked ? 1.5 : 1,
        ),
        boxShadow: locked ? null : AppColors.primaryGlow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.v2InfoPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: locked
                        ? palette.cardSecondary
                        : iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      icon,
                      color: locked ? palette.textTertiary : iconColor,
                      size: 24,
                    ),
                  ),
                ),
                if (locked)
                  const Positioned(
                    top: -4,
                    left: -4,
                    child: Icon(
                      Icons.lock_rounded,
                      color: AppColors.gold,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (showProBadge && proBadgeLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: V2ShellVisual.goldTagDecoration(),
                          child: Text(
                            proBadgeLabel!,
                            style: V2ShellVisual.goldTagLabel(theme),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: V2ShellVisual.captionMuted(theme),
                  ),
                  if (scienceBadgeLabel != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDim,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        scienceBadgeLabel!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: palette.cardSecondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 14,
                              color: palette.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        label: difficultyLabel,
                        child: Row(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                width: 7,
                                height: 7,
                                margin:
                                    const EdgeInsetsDirectional.only(end: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < dots
                                      ? _difficultyColor(difficulty)
                                      : palette.border,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!locked)
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: palette.textTertiary,
              ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignConstants.v2GapControl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          child: locked
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDesignConstants.radiusCard),
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: card,
                  ),
                )
              : card,
        ),
      ),
    );
  }

  Color _difficultyColor(ExerciseLibraryDifficulty difficulty) {
    return switch (difficulty) {
      ExerciseLibraryDifficulty.easy => AppColors.primary,
      ExerciseLibraryDifficulty.medium => AppColors.warning,
      ExerciseLibraryDifficulty.hard => AppColors.danger,
    };
  }
}
