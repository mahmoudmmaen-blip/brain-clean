import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tab-pill filters on the exercise library screen.
enum ExerciseLibraryFilter {
  all,
  memory,
  focus,
  speed,
}

enum ExerciseLibraryTier {
  free,
  pro,
}

enum ExerciseLibraryDifficulty {
  easy,
  medium,
  hard,
}

enum ExerciseLibraryLaunch {
  nBack,
  stroop,
  digitSpan,
  goNoGo,
  focusedReading,
  hiit,
  patternMatch,
}

class ExerciseLibraryItem {
  const ExerciseLibraryItem({
    required this.id,
    required this.tier,
    required this.categories,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.titleKey,
    required this.subtitleKey,
    required this.launch,
    required this.estimatedMinutes,
    required this.difficulty,
  });

  final String id;
  final ExerciseLibraryTier tier;
  final Set<ExerciseLibraryFilter> categories;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String titleKey;
  final String subtitleKey;
  final ExerciseLibraryLaunch launch;
  final int estimatedMinutes;
  final ExerciseLibraryDifficulty difficulty;

  bool matchesFilter(ExerciseLibraryFilter filter) {
    if (filter == ExerciseLibraryFilter.all) {
      return true;
    }
    return categories.contains(filter);
  }
}

/// Static catalog for the V2 exercise library tab.
abstract final class ExerciseLibraryCatalog {
  static const items = <ExerciseLibraryItem>[
    ExerciseLibraryItem(
      id: 'n_back',
      tier: ExerciseLibraryTier.free,
      categories: {ExerciseLibraryFilter.memory},
      icon: Icons.hub_outlined,
      iconBg: AppColors.primaryDim,
      iconColor: AppColors.primary,
      titleKey: 'v2ExercisesNBackTitle',
      subtitleKey: 'v2ExercisesNBackSubtitle',
      launch: ExerciseLibraryLaunch.nBack,
      estimatedMinutes: 8,
      difficulty: ExerciseLibraryDifficulty.hard,
    ),
    ExerciseLibraryItem(
      id: 'stroop',
      tier: ExerciseLibraryTier.free,
      categories: {ExerciseLibraryFilter.focus},
      icon: Icons.palette_outlined,
      iconBg: AppColors.infoDim,
      iconColor: AppColors.info,
      titleKey: 'v2ExercisesStroopTitle',
      subtitleKey: 'v2ExercisesStroopSubtitle',
      launch: ExerciseLibraryLaunch.stroop,
      estimatedMinutes: 5,
      difficulty: ExerciseLibraryDifficulty.medium,
    ),
    ExerciseLibraryItem(
      id: 'digit_span',
      tier: ExerciseLibraryTier.pro,
      categories: {ExerciseLibraryFilter.memory},
      icon: Icons.dialpad_outlined,
      iconBg: AppColors.goldDim,
      iconColor: AppColors.gold,
      titleKey: 'v2ExercisesDigitSpanTitle',
      subtitleKey: 'v2ExercisesDigitSpanSubtitle',
      launch: ExerciseLibraryLaunch.digitSpan,
      estimatedMinutes: 6,
      difficulty: ExerciseLibraryDifficulty.medium,
    ),
    ExerciseLibraryItem(
      id: 'go_no_go',
      tier: ExerciseLibraryTier.pro,
      categories: {ExerciseLibraryFilter.focus, ExerciseLibraryFilter.speed},
      icon: Icons.bolt_outlined,
      iconBg: AppColors.goldDim,
      iconColor: AppColors.gold,
      titleKey: 'v2ExercisesGoNoGoTitle',
      subtitleKey: 'v2ExercisesGoNoGoSubtitle',
      launch: ExerciseLibraryLaunch.goNoGo,
      estimatedMinutes: 5,
      difficulty: ExerciseLibraryDifficulty.medium,
    ),
    ExerciseLibraryItem(
      id: 'focused_reading',
      tier: ExerciseLibraryTier.pro,
      categories: {ExerciseLibraryFilter.focus},
      icon: Icons.auto_stories_outlined,
      iconBg: AppColors.goldDim,
      iconColor: AppColors.gold,
      titleKey: 'v2ExercisesReadingComprehensionTitle',
      subtitleKey: 'v2ExercisesReadingComprehensionSubtitle',
      launch: ExerciseLibraryLaunch.focusedReading,
      estimatedMinutes: 10,
      difficulty: ExerciseLibraryDifficulty.easy,
    ),
    ExerciseLibraryItem(
      id: 'hiit',
      tier: ExerciseLibraryTier.pro,
      categories: {ExerciseLibraryFilter.focus, ExerciseLibraryFilter.speed},
      icon: Icons.timer_outlined,
      iconBg: AppColors.goldDim,
      iconColor: AppColors.gold,
      titleKey: 'v2ExercisesHiitTitle',
      subtitleKey: 'v2ExercisesHiitSubtitle',
      launch: ExerciseLibraryLaunch.hiit,
      estimatedMinutes: 7,
      difficulty: ExerciseLibraryDifficulty.hard,
    ),
    ExerciseLibraryItem(
      id: 'pattern_match',
      tier: ExerciseLibraryTier.pro,
      categories: {ExerciseLibraryFilter.speed, ExerciseLibraryFilter.memory},
      icon: Icons.grid_view_rounded,
      iconBg: AppColors.goldDim,
      iconColor: AppColors.gold,
      titleKey: 'v2ExercisesPatternMatchTitle',
      subtitleKey: 'v2ExercisesPatternMatchSubtitle',
      launch: ExerciseLibraryLaunch.patternMatch,
      estimatedMinutes: 5,
      difficulty: ExerciseLibraryDifficulty.medium,
    ),
  ];

  static List<ExerciseLibraryItem> forFilter(ExerciseLibraryFilter filter) {
    return items.where((item) => item.matchesFilter(filter)).toList(growable: false);
  }

  static List<ExerciseLibraryItem> forTierAndFilter(
    ExerciseLibraryTier tier,
    ExerciseLibraryFilter filter,
  ) {
    return forFilter(filter).where((item) => item.tier == tier).toList(growable: false);
  }
}
