import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/confirm_dialog.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../content/goal_tips_content.dart';
import '../../data/day_progress.dart';
import '../../domain/program_engine.dart';
import '../../domain/western_digits.dart';
import '../../routing/v3_routes.dart';
import 'evening_check_in_sheet.dart';
import 'trial_ending_sheet.dart';

enum TodayHeroState { notStarted, inProgress, done, proLocked }

enum EveningSlotState { locked, open, done }

class V3TodayScreen extends ConsumerWidget {
  const V3TodayScreen({super.key, this.nowOverride});

  /// Injectable clock for widget tests.
  final DateTime? nowOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final isPro = ref.watch(isProUserProvider);
    final appAsync = ref.watch(v3AppStateProvider);
    final contentAsync = ref.watch(v3ContentProvider);
    final now = nowOverride ?? DateTime.now();

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        return appAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (app) {
            final engineCurrent = ProgramEngine.currentDay(app.dayProgress);
            final unlocked = ProgramEngine.isDayUnlocked(
              day: engineCurrent,
              now: now,
              progress: app.dayProgress,
            );
            // After finishing day X, next day waits until midnight — show X as done.
            final displayDay = (!unlocked && engineCurrent > 1)
                ? engineCurrent - 1
                : engineCurrent;
            final progress = app.progressForDay(displayDay);
            final dayContent = bundle.program.dayByNumber(displayDay);
            final week = dayContent == null
                ? null
                : bundle.program.weeks
                    .where((w) => w.week == dayContent.week)
                    .firstOrNull;
            final daysPracticed =
                ProgramEngine.completedDayCount(app.dayProgress);
            final programFinished =
                ProgramEngine.isProgramFinished(app.dayProgress);
            final streak = ProgramEngine.currentStreak(
              progress: app.dayProgress,
              now: now,
            );
            final proLocked = ProgramEngine.isProLocked(
              day: displayDay,
              isPro: isPro,
            );
            if (programFinished) {
              return TrialEndingHost(
                child: Scaffold(
                  key: const Key('v3_today_screen'),
                  backgroundColor: AppDesignConstants.darkBackground,
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDesignConstants.paddingScreen,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                key: const Key('v3_today_settings'),
                                tooltip: loc.v3SettingsTooltip,
                                onPressed: () =>
                                    context.push(V3Routes.settings),
                                icon: const Icon(Icons.settings_outlined),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            loc.v3AfterProgramTitle,
                            key: const Key('v3_today_after_program'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.v3GraduationDays(daysPracticed),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          FilledButton(
                            key: const Key('v3_today_after_tools'),
                            onPressed: () => context.go(V3Routes.tools),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppDesignConstants.brandGreen,
                              minimumSize: const Size(48, 48),
                            ),
                            child: Text(loc.v3AfterProgramTools),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            key: const Key('v3_today_after_clarity'),
                            onPressed: () => context.push(
                              V3Routes.checkPath(mode: 'recheck'),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            child: Text(loc.v3AfterProgramClarity),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            key: const Key('v3_today_after_restart'),
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                title: loc.v3AfterProgramRestartConfirmTitle,
                                message: loc.v3AfterProgramRestartConfirmBody,
                                confirmLabel: loc.commonConfirm,
                                cancelLabel: loc.commonCancel,
                                destructive: true,
                              );
                              if (!ok) return;
                              await ref
                                  .read(v3StateRepositoryProvider)
                                  .clearDayProgressOnly();
                              ref.invalidate(v3AppStateProvider);
                            },
                            child: Text(loc.v3AfterProgramRestart),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            key: const Key('v3_today_sos'),
                            onPressed: () => context.push(V3Routes.sos),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: Text(loc.v3SosButton),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            final hero = _heroState(
              progress: progress,
              proLocked: proLocked,
              waitingForMidnight: !unlocked && engineCurrent > 1,
            );
            final latestScore = app.clarityResults.isEmpty
                ? null
                : app.clarityResults.last.score;
            final nextCheck = ProgramEngine.nextClarityCheckDay(
              schedule: bundle.clarityCheck.schedule,
              clarityTakenOnProgramDays:
                  app.clarityResults.map((r) => r.programDay).toSet(),
            );
            final eveningDone = app.eveningCheckIns.any((e) {
              final today =
                  '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              return e.date == today;
            });
            final eveningState = eveningDone
                ? EveningSlotState.done
                : (now.hour >= 18
                    ? EveningSlotState.open
                    : EveningSlotState.locked);
            final name = app.profile?.name;
            final greeting = name == null || name.isEmpty
                ? loc.v3GreetingHello
                : loc.v3GreetingNamed(_daypart(loc, now), name);
            final tipWeek = ((displayDay - 1) ~/ 7) + 1;
            final cappedTipWeek = tipWeek > 4 ? 4 : tipWeek;
            final showGoalTip = displayDay <= 30;
            final profileGoal =
                app.profile?.goal ?? GoalTipsContent.fallbackGoal;
            final String? goalTipText = !showGoalTip
                ? null
                : bundle.goalTips.tip(
                    goal: profileGoal,
                    week: cappedTipWeek,
                    locale: locale,
                  );

            return TrialEndingHost(
              child: Scaffold(
                key: const Key('v3_today_screen'),
                backgroundColor: AppDesignConstants.darkBackground,
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(
                            AppDesignConstants.paddingScreen,
                          ),
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  key: const Key('v3_today_settings'),
                                  tooltip: loc.v3SettingsTooltip,
                                  onPressed: () =>
                                      context.push(V3Routes.settings),
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                                Expanded(
                                  child: Text(
                                    greeting,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _DaysPracticedHero(
                              daysPracticed: daysPracticed,
                              displayDay: displayDay,
                              streak: streak,
                            ),
                            const SizedBox(height: 20),
                            if (dayContent != null)
                              _HeroCard(
                                day: displayDay,
                                weekLabel: week == null
                                    ? ''
                                    : loc.v3WeekLabel(
                                        week.week,
                                        week.title.resolve(locale),
                                      ),
                                lessonTitle:
                                    dayContent.lesson.title.resolve(locale),
                                minutes: loc.v3AboutMinutes(10),
                                state: hero,
                                onPrimary: () {
                                  if (hero == TodayHeroState.proLocked) {
                                    context.push(
                                      '${V3Routes.paywall}?source=locked_day',
                                    );
                                  } else {
                                    context.push(
                                      V3Routes.sessionPath(displayDay),
                                    );
                                  }
                                },
                                onReview: () => context.push(
                                  V3Routes.sessionPath(displayDay),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _EveningSlot(
                              state: eveningState,
                              onOpen: eveningState == EveningSlotState.open
                                  ? () => showEveningCheckInSheet(
                                        context,
                                        reflection: dayContent?.reflection
                                                .resolve(locale) ??
                                            '',
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            if (dayContent != null)
                              _ChallengeCard(
                                text: dayContent.challenge.resolve(locale),
                                checked: progress?.challengeDone == true,
                                onChanged: (v) async {
                                  final base = progress ??
                                      DayProgress(
                                        day: displayDay,
                                        lessonDone: false,
                                        practiceDone: false,
                                        usedEasy: false,
                                        challengeAccepted: false,
                                      );
                                  await ref
                                      .read(v3StateRepositoryProvider)
                                      .saveDayProgress(
                                        base.copyWith(challengeDone: v),
                                      );
                                  ref.invalidate(v3AppStateProvider);
                                },
                              ),
                            if (goalTipText != null) ...[
                              const SizedBox(height: 16),
                              _GoalTipCard(
                                goal: profileGoal,
                                tip: goalTipText,
                              ),
                            ],
                            const SizedBox(height: 16),
                            _ClarityCard(
                              score: latestScore,
                              nextDay: nextCheck,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDesignConstants.paddingScreen,
                          8,
                          AppDesignConstants.paddingScreen,
                          12,
                        ),
                        child: OutlinedButton(
                          key: const Key('v3_today_sos'),
                          onPressed: () => context.push(V3Routes.sos),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(
                              color: AppDesignConstants.brandGreen,
                            ),
                          ),
                          child: Text(loc.v3SosButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static TodayHeroState _heroState({
    required DayProgress? progress,
    required bool proLocked,
    required bool waitingForMidnight,
  }) {
    if (proLocked) return TodayHeroState.proLocked;
    if (waitingForMidnight || progress?.completedAt != null) {
      return TodayHeroState.done;
    }
    if (progress?.startedAt != null ||
        progress?.lessonDone == true ||
        progress?.practiceDone == true) {
      return TodayHeroState.inProgress;
    }
    return TodayHeroState.notStarted;
  }

  static String _daypart(AppLocalizations loc, DateTime now) {
    if (now.hour < 12) return loc.v3DaypartMorning;
    if (now.hour < 18) return loc.v3DaypartAfternoon;
    return loc.v3DaypartEvening;
  }
}

class _DaysPracticedHero extends StatelessWidget {
  const _DaysPracticedHero({
    required this.daysPracticed,
    required this.displayDay,
    required this.streak,
  });

  final int daysPracticed;
  final int displayDay;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const Key('v3_today_days_practiced'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loc.v3PaywallChipDays(daysPracticed),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orangeAccent,
              size: 18,
            ),
            const SizedBox(width: 2),
            Text(
              WesternDigits.formatInt(streak),
              key: const Key('v3_today_streak'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppDesignConstants.darkOnSurfaceMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          loc.v3DayOf(displayDay, 30),
          style: const TextStyle(
            fontSize: 13,
            color: AppDesignConstants.darkOnSurfaceMuted,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: displayDay / 30,
            minHeight: 6,
            backgroundColor: AppDesignConstants.darkBorder,
            color: AppDesignConstants.brandGreen,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.day,
    required this.weekLabel,
    required this.lessonTitle,
    required this.minutes,
    required this.state,
    required this.onPrimary,
    required this.onReview,
  });

  final int day;
  final String weekLabel;
  final String lessonTitle;
  final String minutes;
  final TodayHeroState state;
  final VoidCallback onPrimary;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final done = state == TodayHeroState.done;
    return Container(
      key: Key('v3_today_hero_${state.name}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done
            ? AppDesignConstants.brandGreen.withValues(alpha: 0.18)
            : AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: done
            ? Border.all(
                color: AppDesignConstants.brandGreen.withValues(alpha: 0.5),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            weekLabel,
            style: const TextStyle(
              color: AppDesignConstants.darkOnSurfaceMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lessonTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            minutes,
            style: const TextStyle(
              color: AppDesignConstants.darkOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: 14),
          if (done) ...[
            Text(
              loc.v3HeroDone(day),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton(
              key: const Key('v3_today_hero_review'),
              onPressed: onReview,
              child: Text(loc.v3HeroReview),
            ),
          ] else
            FilledButton(
              key: const Key('v3_today_hero_cta'),
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: state == TodayHeroState.proLocked
                    ? AppDesignConstants.accentGold
                    : AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(switch (state) {
                TodayHeroState.notStarted => loc.v3HeroStart(day),
                TodayHeroState.inProgress => loc.v3HeroContinue,
                TodayHeroState.proLocked => loc.v3HeroUnlockPro,
                TodayHeroState.done => loc.v3HeroContinue,
              }),
            ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.text,
    required this.checked,
    required this.onChanged,
  });

  final String text;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      key: const Key('v3_today_challenge'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CheckboxListTile(
        value: checked,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(loc.v3TodayChallenge),
        subtitle: Text(text),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _EveningSlot extends StatelessWidget {
  const _EveningSlot({required this.state, this.onOpen});

  final EveningSlotState state;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final label = switch (state) {
      EveningSlotState.locked => loc.v3EveningSlotLocked,
      EveningSlotState.open => loc.v3EveningSlotOpen,
      EveningSlotState.done => loc.v3EveningSlotDone,
    };
    final key = Key('v3_today_evening_${state.name}');
    return Material(
      color: AppDesignConstants.darkSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(20),
        onTap: state == EveningSlotState.open ? onOpen : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: state == EveningSlotState.locked
                  ? AppDesignConstants.darkOnSurfaceMuted
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalTipCard extends StatelessWidget {
  const _GoalTipCard({required this.goal, required this.tip});

  final String goal;
  final String tip;

  static IconData iconFor(String goal) {
    switch (GoalTipsContent.mapProfileGoal(goal)) {
      case 'focus':
        return Icons.center_focus_strong_outlined;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'calm':
        return Icons.spa_outlined;
      case 'less_scroll':
      default:
        return Icons.smartphone_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('v3_today_goal_tip'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconFor(goal), color: AppDesignConstants.brandGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClarityCard extends StatelessWidget {
  const _ClarityCard({required this.score, required this.nextDay});

  final int? score;
  final int? nextDay;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      key: const Key('v3_today_clarity'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${loc.v3ClarityScoreLabel}${score == null ? '' : ': $score'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (nextDay != null)
            Text(
              loc.v3NextClarityCheck(nextDay!),
              style: const TextStyle(
                color: AppDesignConstants.darkOnSurfaceMuted,
              ),
            ),
        ],
      ),
    );
  }
}
