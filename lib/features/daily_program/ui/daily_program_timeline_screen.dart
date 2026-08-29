import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../daily_session/data/home_dashboard_provider.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../application/structured_daily_program_provider.dart';
import '../domain/adaptive_program_protocol.dart';
import '../domain/daily_program_activity_kind.dart';
import '../domain/structured_daily_activity.dart';
import '../domain/structured_daily_activity_l10n.dart';

/// Flight-plan style daily program timeline (adaptive engine → tasks).
class DailyProgramTimelineScreen extends ConsumerWidget {
  const DailyProgramTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final palette = AppColors.of(context);
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final async = ref.watch(structuredDailyProgramForDayProvider(day));
    final dashboard = ref.watch(homeDashboardProvider).valueOrNull;
    final isPro = ref.watch(isProUserProvider);
    final programDay = dashboard?.programDay ?? 1;
    final dayInWeek = ((programDay < 1 ? 1 : programDay) - 1) % 7;

    return Scaffold(
      backgroundColor: palette.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isPro) {
            context.push(AppRoutes.v2Progress);
          } else {
            context.push(AppRoutes.v2PremiumWithSource('brain_map'));
          }
        },
        backgroundColor: palette.card,
        icon: Icon(
          Icons.psychology,
          color: isPro ? AppColors.primary : AppColors.gold,
        ),
        label: Text(
          loc.dailyProgramBrainMapCta,
          style: TextStyle(
            color: isPro ? AppColors.primary : AppColors.goldText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDesignConstants.paddingScreen,
                8,
                AppDesignConstants.paddingScreen,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: palette.textPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.v2Home);
                      }
                    },
                  ),
                  Expanded(
                    child: async.when(
                      loading: () => Text(
                        loc.v2TodayHomeLoading,
                        textAlign: TextAlign.end,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                      error: (_, __) => Text(
                        loc.homeDailyProgramEmptyTitle,
                        textAlign: TextAlign.end,
                        style: TextStyle(color: palette.textPrimary),
                      ),
                      data: (view) => _HeaderTitles(
                        loc: loc,
                        programDay: programDay,
                        plan: view.plan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignConstants.paddingScreen,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final isActive = index == dayInWeek;
                  final isDone = index < dayInWeek;
                  return _WeekDot(
                    dayNumber: index + 1,
                    isActive: isActive,
                    isDone: isDone,
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      loc.homeDailyProgramEmptyBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ),
                ),
                data: (view) {
                  if (view.activities.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              view.plan.freeResetComplete
                                  ? loc.adaptiveProgramFreeResetCompleteBody
                                  : loc.homeDailyProgramEmptyBody,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: palette.textPrimary),
                            ),
                            if (view.showProLock) ...[
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => context.push(
                                  AppRoutes.v2PremiumWithSource(
                                    'daily_program',
                                  ),
                                ),
                                style: V2ShellVisual.primaryFilled(),
                                child: Text(loc.homeUpgradeToPro),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  final currentIndex =
                      view.activities.indexWhere((a) => !a.completed);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDesignConstants.paddingScreen,
                      0,
                      AppDesignConstants.paddingScreen,
                      100,
                    ),
                    itemCount: view.activities.length,
                    itemBuilder: (context, index) {
                      final activity = view.activities[index];
                      final isCurrent =
                          index == currentIndex && !activity.completed;
                      return _TaskTimelineCard(
                        loc: loc,
                        activity: activity,
                        timeLabel: _slotLabel(index),
                        isCurrent: isCurrent,
                        isLast: index == view.activities.length - 1,
                        onStart: () => _openActivity(
                          context: context,
                          ref: ref,
                          loc: loc,
                          day: day,
                          activity: activity,
                        ),
                        onToggleComplete: () {
                          ref
                              .read(structuredDailyProgramControllerProvider)
                              .toggle(
                                day: day,
                                activityId: activity.id,
                                completed: !activity.completed,
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _slotLabel(int index) {
    const slots = ['07:00', '09:00', '12:00', '16:00', '18:00', '21:00'];
    return slots[index % slots.length];
  }
}

class _HeaderTitles extends StatelessWidget {
  const _HeaderTitles({
    required this.loc,
    required this.programDay,
    required this.plan,
  });

  final AppLocalizations loc;
  final int programDay;
  final AdaptiveProgramPlan plan;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final protocolTitle = switch (plan.protocol) {
      AdaptiveProgramProtocol.base => loc.adaptiveProgramBaseTitle,
      AdaptiveProgramProtocol.resetProtocol => loc.adaptiveProgramResetTitle,
      AdaptiveProgramProtocol.neuralAscension =>
        loc.adaptiveProgramAscensionTitle,
      AdaptiveProgramProtocol.enhancedMind =>
        loc.adaptiveProgramEnhancedMindTitle,
    };
    final phase = _phaseLabel(loc, plan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          loc.dailyProgramDayPhaseTitle(programDay, phase),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          protocolTitle,
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _phaseLabel(AppLocalizations loc, AdaptiveProgramPlan plan) {
    if (plan.protocol == AdaptiveProgramProtocol.resetProtocol) {
      return loc.dailyProgramPhaseWeek(plan.protocolWeek.clamp(1, 4));
    }
    if (plan.protocol == AdaptiveProgramProtocol.neuralAscension) {
      if (plan.protocolWeek <= 2) return loc.dailyProgramPhasePurge;
      if (plan.protocolWeek <= 5) return loc.dailyProgramPhaseBuild;
      if (plan.protocolWeek <= 8) return loc.dailyProgramPhaseOptimize;
      return loc.dailyProgramPhaseMaintain;
    }
    if (plan.protocol == AdaptiveProgramProtocol.enhancedMind) {
      return loc.dailyProgramPhaseMaintain;
    }
    return loc.adaptiveProgramBaseGoal;
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.dayNumber,
    required this.isActive,
    required this.isDone,
  });

  final int dayNumber;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppColors.primary
            : isActive
                ? AppColors.primary.withValues(alpha: 0.2)
                : palette.cardSecondary,
        border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, color: AppColors.onPrimary, size: 16)
            : Text(
                '$dayNumber',
                style: TextStyle(
                  color: isActive ? AppColors.primary : palette.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _TaskTimelineCard extends StatelessWidget {
  const _TaskTimelineCard({
    required this.loc,
    required this.activity,
    required this.timeLabel,
    required this.isCurrent,
    required this.isLast,
    required this.onStart,
    required this.onToggleComplete,
  });

  final AppLocalizations loc;
  final StructuredDailyActivity activity;
  final String timeLabel;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback onStart;
  final VoidCallback onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final kind = resolveDailyProgramActivityKind(
      id: activity.id,
      titleKey: activity.titleKey,
    );
    final title = resolveStructuredDailyActivityTitle(loc, activity.titleKey);
    final categoryColor = _categoryColor(kind);
    final isCompleted = activity.completed;

    return Opacity(
      opacity: isCompleted ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Text(
                timeLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCurrent ? AppColors.primary : palette.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : palette.cardSecondary,
                    border: isCurrent && !isCompleted
                        ? Border.all(color: palette.textPrimary, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: AppColors.onPrimary,
                          size: 10,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 56,
                    color: palette.cardSecondary,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent ? palette.cardSecondary : palette.card,
                  borderRadius:
                      BorderRadius.circular(AppDesignConstants.radiusCard),
                  border: isCurrent
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        )
                      : Border.all(color: palette.border),
                  boxShadow: isCurrent ? AppColors.primaryGlow : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isCompleted
                                  ? palette.textTertiary
                                  : palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            loc.dailyProgramMinutesOnly(activity.minutes),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (activity.isAdaptive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              loc.dailyProgramAdaptiveBadge,
                              style: const TextStyle(
                                color: AppColors.goldText,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        if (activity.isOptional) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              loc.dailyProgramOptionalBadge,
                              style: const TextStyle(
                                color: AppColors.info,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.dailyProgramTimelineHint,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    if (isCurrent && !isCompleted) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: AppDesignConstants.minTouchTarget,
                        child: FilledButton(
                          onPressed: onStart,
                          style: V2ShellVisual.primaryFilled(),
                          child: Text(loc.dailyProgramStartSessionCta),
                        ),
                      ),
                    ],
                    if (!isCurrent || isCompleted) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: onToggleComplete,
                          child: Text(
                            isCompleted
                                ? loc.dailyProgramMarkIncomplete
                                : loc.dailyProgramMarkComplete,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(DailyProgramActivityKind kind) {
    return switch (kind) {
      DailyProgramActivityKind.pomodoro ||
      DailyProgramActivityKind.reading ||
      DailyProgramActivityKind.physical =>
        AppColors.primary,
      DailyProgramActivityKind.cognitiveNBack ||
      DailyProgramActivityKind.cognitiveStroop ||
      DailyProgramActivityKind.cognitiveDigitSpan ||
      DailyProgramActivityKind.iqChallenge =>
        AppColors.accentPurple,
      DailyProgramActivityKind.screenFree => AppColors.accentPink,
      DailyProgramActivityKind.nsdr ||
      DailyProgramActivityKind.whiteNoise =>
        AppColors.accentBlue,
      DailyProgramActivityKind.eveningReview => AppColors.accentOrange,
      DailyProgramActivityKind.rule ||
      DailyProgramActivityKind.other =>
        AppColors.textSecondary,
    };
  }
}

Future<void> _openActivity({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations loc,
  required DateTime day,
  required StructuredDailyActivity activity,
}) async {
  final kind = resolveDailyProgramActivityKind(
    id: activity.id,
    titleKey: activity.titleKey,
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
      await ref.read(structuredDailyProgramControllerProvider).toggle(
            day: day,
            activityId: activity.id,
            completed: true,
          );
  }
}
