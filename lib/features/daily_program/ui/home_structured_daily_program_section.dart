import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../application/structured_daily_program_provider.dart';
import '../data/adaptive_program_state_provider.dart';
import '../domain/adaptive_program_protocol.dart';
import '../domain/daily_program_activity_kind.dart';
import '../domain/structured_daily_activity.dart';
import '../domain/structured_daily_activity_l10n.dart';

/// Scroll target for Home Pomodoro card (daily program deep-link).
/// Non-global key — MaterialApp theme remounts must not share a GlobalKey.
final homePomodoroAnchorKey = ValueKey<String>('home_pomodoro_anchor');

/// Checkable structured daily program cards for Home.
class HomeStructuredDailyProgramSection extends ConsumerWidget {
  const HomeStructuredDailyProgramSection({
    super.key,
    required this.loc,
    required this.selectedDay,
  });

  final AppLocalizations loc;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(structuredDailyProgramForDayProvider(selectedDay));
    final palette = AppColors.of(context);

    return async.when(
      loading: () => V2InfoCard(
        child: Text(
          loc.v2TodayHomeLoading,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      error: (_, __) => V2InfoCard(
        child: Text(
          loc.homeDailyProgramEmptyBody,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      data: (view) {
        final doneCount =
            view.activities.where((a) => a.completed).length;
        final totalCount = view.activities.length;
        final allDone = totalCount > 0 && doneCount == totalCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (view.plan.protocol != AdaptiveProgramProtocol.base) ...[
              _ProtocolBanner(loc: loc, plan: view.plan),
              const SizedBox(height: AppDesignConstants.v2GapControl),
            ],
            if (totalCount > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.homeDailyProgramProgress(doneCount, totalCount),
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${((doneCount / totalCount) * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: totalCount == 0 ? 0 : doneCount / totalCount,
                  minHeight: 6,
                  backgroundColor: palette.cardSecondary,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDesignConstants.v2GapControl),
            ],
            if (view.showTestsBanner) ...[
              _TestsMotivationBanner(loc: loc),
              const SizedBox(height: AppDesignConstants.v2GapControl),
            ],
            if (view.plan.freeResetComplete) ...[
              V2InfoCard(
                child: Text(
                  loc.adaptiveProgramFreeResetCompleteBody,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppDesignConstants.v2GapControl),
            ],
            if (view.activities.isEmpty && !view.plan.freeResetComplete)
              V2InfoCard(
                child: Text(
                  loc.homeDailyProgramEmptyBody,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              )
            else if (view.activities.isNotEmpty)
              for (final activity in view.activities) ...[
                _ActivityCheckCard(
                  loc: loc,
                  activity: activity,
                  selectedDay: selectedDay,
                  onToggle: (value) {
                    ref.read(structuredDailyProgramControllerProvider).toggle(
                          day: selectedDay,
                          activityId: activity.id,
                          completed: value,
                        );
                  },
                ),
                const SizedBox(height: AppDesignConstants.v2GapInline),
              ],
            if (allDone && view.activities.isNotEmpty) ...[
              const SizedBox(height: AppDesignConstants.v2GapControl),
              _FeelingPrompt(
                loc: loc,
                selectedDay: selectedDay,
              ),
            ],
            if (view.showProLock) ...[
              const SizedBox(height: AppDesignConstants.v2GapControl),
              _ProPersonalizedLockRow(
                loc: loc,
                freeResetComplete: view.plan.freeResetComplete,
              ),
            ],
            const SizedBox(height: AppDesignConstants.v2GapControl),
            Text(
              loc.dailyProgramBenefitLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProtocolBanner extends StatelessWidget {
  const _ProtocolBanner({required this.loc, required this.plan});

  final AppLocalizations loc;
  final AdaptiveProgramPlan plan;

  String _title() {
    return switch (plan.protocol) {
      AdaptiveProgramProtocol.base => loc.adaptiveProgramBaseTitle,
      AdaptiveProgramProtocol.resetProtocol => loc.adaptiveProgramResetTitle,
      AdaptiveProgramProtocol.neuralAscension =>
        loc.adaptiveProgramAscensionTitle,
      AdaptiveProgramProtocol.enhancedMind =>
        loc.adaptiveProgramEnhancedMindTitle,
    };
  }

  String _goal() {
    return switch (plan.weekGoalKey) {
      'adaptiveProgramBaseGoal' => loc.adaptiveProgramBaseGoal,
      'adaptiveProgramResetWeek1Goal' => loc.adaptiveProgramResetWeek1Goal,
      'adaptiveProgramResetWeek2Goal' => loc.adaptiveProgramResetWeek2Goal,
      'adaptiveProgramResetWeek3Goal' => loc.adaptiveProgramResetWeek3Goal,
      'adaptiveProgramResetWeek4Goal' => loc.adaptiveProgramResetWeek4Goal,
      'adaptiveProgramAscensionPhase1Goal' =>
        loc.adaptiveProgramAscensionPhase1Goal,
      'adaptiveProgramAscensionPhase2Goal' =>
        loc.adaptiveProgramAscensionPhase2Goal,
      'adaptiveProgramAscensionPhase3Goal' =>
        loc.adaptiveProgramAscensionPhase3Goal,
      'adaptiveProgramAscensionPhase4Goal' =>
        loc.adaptiveProgramAscensionPhase4Goal,
      'adaptiveProgramEnhancedMindGoal' => loc.adaptiveProgramEnhancedMindGoal,
      'adaptiveProgramFreeResetCompleteGoal' =>
        loc.adaptiveProgramFreeResetCompleteGoal,
      _ => loc.adaptiveProgramBaseGoal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _title(),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                loc.adaptiveProgramWeekLabel(plan.protocolWeek),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _goal(),
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (plan.showWeekendChallenge) ...[
            const SizedBox(height: 8),
            Text(
              loc.adaptiveProgramWeekendUnlocked,
              style: const TextStyle(
                color: AppColors.goldText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeelingPrompt extends ConsumerWidget {
  const _FeelingPrompt({
    required this.loc,
    required this.selectedDay,
  });

  final AppLocalizations loc;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayKey = structuredDailyProgramDayKey(selectedDay);
    final adaptive = ref.watch(adaptiveProgramStateProvider);
    if (adaptive.lastCompletedDayKey == dayKey &&
        adaptive.lastFeeling != null) {
      return const SizedBox.shrink();
    }

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.adaptiveProgramFeelingPrompt,
            style: TextStyle(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FeelingChip(
                  label: loc.adaptiveProgramFeelingHard,
                  onTap: () => ref
                      .read(structuredDailyProgramControllerProvider)
                      .recordFeeling(
                        day: selectedDay,
                        feeling: AdaptiveSessionFeeling.hard,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeelingChip(
                  label: loc.adaptiveProgramFeelingOk,
                  onTap: () => ref
                      .read(structuredDailyProgramControllerProvider)
                      .recordFeeling(
                        day: selectedDay,
                        feeling: AdaptiveSessionFeeling.ok,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeelingChip(
                  label: loc.adaptiveProgramFeelingEasy,
                  onTap: () => ref
                      .read(structuredDailyProgramControllerProvider)
                      .recordFeeling(
                        day: selectedDay,
                        feeling: AdaptiveSessionFeeling.easy,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeelingChip extends StatelessWidget {
  const _FeelingChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.of(context).cardSecondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDesignConstants.minTouchTarget,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestsMotivationBanner extends StatelessWidget {
  const _TestsMotivationBanner({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return KeyedSubtree(
      key: const Key('daily_program_tests_banner'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(AppRoutes.v2Tests),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.dailyProgramTestsBannerTitle,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: AppDesignConstants.minTouchTarget,
                    child: FilledButton(
                      key: const Key('daily_program_tests_banner_cta'),
                      onPressed: () => context.push(AppRoutes.v2Tests),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.goldDim,
                        foregroundColor: AppColors.goldText,
                      ),
                      child: Text(
                        loc.dailyProgramTestsBannerCta,
                        style: const TextStyle(
                          color: AppColors.goldText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCheckCard extends ConsumerWidget {
  const _ActivityCheckCard({
    required this.loc,
    required this.activity,
    required this.selectedDay,
    required this.onToggle,
  });

  final AppLocalizations loc;
  final StructuredDailyActivity activity;
  final DateTime selectedDay;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = resolveDailyProgramActivityKind(
      id: activity.id,
      titleKey: activity.titleKey,
    );
    final title = resolveStructuredDailyActivityTitle(loc, activity.titleKey);
    final accent = _accentFor(kind);
    final icon = _iconFor(kind);
    final durationLabel = loc.dailyProgramMinutesOnly(activity.minutes);

    final isAdaptive = activity.isAdaptive;
    final borderColor = isAdaptive
        ? const Color(0xFFE3B155)
        : const Color(0xFF233029);
    final borderWidth = isAdaptive ? 2.0 : 1.0;

    // Absolute Chrome-safe card: uniform border only, hardcoded text color,
    // Material Icons only, no custom fonts, no IntrinsicHeight.
    return GestureDetector(
      key: Key('structured_daily_activity_${activity.id}'),
      onTap: () => _onOpen(context, ref, kind),
      onLongPress: () => onToggle(!activity.completed),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isAdaptive
              ? const Color(0xFF1F1A10)
              : const Color(0xFF141B17),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: isAdaptive ? const Color(0xFFE3B155) : accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: accent, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdaptive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A2E15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        loc.dailyProgramAdaptiveBadge,
                        style: const TextStyle(
                          color: Color(0xFFF4D08A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title.isEmpty ? activity.titleKey : title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFEDEFEA),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    durationLabel,
                    style: const TextStyle(
                      color: Color(0xFFEDEFEA),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              activity.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: activity.completed
                  ? const Color(0xFF3FD08C)
                  : const Color(0xFF8FA098),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpen(
    BuildContext context,
    WidgetRef ref,
    DailyProgramActivityKind kind,
  ) async {
    final day = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final dayParam =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    switch (kind) {
      case DailyProgramActivityKind.reading:
      case DailyProgramActivityKind.screenFree:
      case DailyProgramActivityKind.physical:
      case DailyProgramActivityKind.nsdr:
      case DailyProgramActivityKind.whiteNoise:
        final title =
            resolveStructuredDailyActivityTitle(loc, activity.titleKey);
        await context.push(
          AppRoutes.v2DailyProgramTimerWith(
            activityId: activity.id,
            minutes: activity.minutes,
            title: title,
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.pomodoro:
        // Prefer dedicated Pomodoro route — ValueKey cannot resolve context.
        await context.push(AppRoutes.pomodoro);
      case DailyProgramActivityKind.cognitiveNBack:
        await context.push(
          AppRoutes.v2DailyProgramCognitiveWith(
            activityId: activity.id,
            kind: 'nback',
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.cognitiveStroop:
        await context.push(
          AppRoutes.v2DailyProgramCognitiveWith(
            activityId: activity.id,
            kind: 'stroop',
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.cognitiveDigitSpan:
        await context.push(AppRoutes.cognitiveMemory);
      case DailyProgramActivityKind.iqChallenge:
        await context.push(AppRoutes.v2IqTest);
        if (context.mounted) {
          await ref.read(structuredDailyProgramControllerProvider).toggle(
                day: day,
                activityId: activity.id,
                completed: true,
              );
        }
      case DailyProgramActivityKind.eveningReview:
        await context.push(
          AppRoutes.v2EveningReviewWith(
            activityId: activity.id,
            day: dayParam,
          ),
        );
      case DailyProgramActivityKind.rule:
      case DailyProgramActivityKind.other:
        onToggle(!activity.completed);
    }
  }

  Color _accentFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => AppColors.gold,
      DailyProgramActivityKind.pomodoro => AppColors.primary,
      DailyProgramActivityKind.screenFree => AppColors.info,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        AppColors.accentPurple,
      DailyProgramActivityKind.iqChallenge => AppColors.accentPurple,
      DailyProgramActivityKind.eveningReview => AppColors.accentOrange,
      DailyProgramActivityKind.physical => AppColors.primary,
      DailyProgramActivityKind.nsdr => AppColors.info,
      DailyProgramActivityKind.whiteNoise => AppColors.accentPurple,
      DailyProgramActivityKind.rule ||
      DailyProgramActivityKind.other =>
        AppColors.textSecondary,
    };
  }

  IconData _iconFor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.reading => Icons.menu_book,
      DailyProgramActivityKind.pomodoro => Icons.timer,
      DailyProgramActivityKind.screenFree => Icons.phone_android,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan =>
        Icons.psychology,
      DailyProgramActivityKind.iqChallenge => Icons.psychology,
      DailyProgramActivityKind.eveningReview => Icons.edit_note,
      DailyProgramActivityKind.physical => Icons.directions_run,
      DailyProgramActivityKind.nsdr => Icons.self_improvement,
      DailyProgramActivityKind.whiteNoise => Icons.headphones,
      DailyProgramActivityKind.rule => Icons.rule,
      DailyProgramActivityKind.other => Icons.check_circle_outline,
    };
  }
}

class _ProPersonalizedLockRow extends StatelessWidget {
  const _ProPersonalizedLockRow({
    required this.loc,
    this.freeResetComplete = false,
  });

  final AppLocalizations loc;
  final bool freeResetComplete;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final title = freeResetComplete
        ? loc.adaptiveProgramFreeResetCompleteTitle
        : loc.adaptiveProgramUnlockFullBody;
    return KeyedSubtree(
      key: const Key('structured_daily_program_pro_lock'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(
            AppRoutes.v2PremiumWithSource('pro_gate'),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.homeUpgradeToPro,
                          style: const TextStyle(
                            color: AppColors.goldText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: palette.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
