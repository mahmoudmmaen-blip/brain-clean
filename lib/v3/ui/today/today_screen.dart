import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../data/day_progress.dart';
import '../../domain/program_engine.dart';
import '../../routing/v3_routes.dart';
import 'evening_check_in_sheet.dart';

enum TodayHeroState { notStarted, inProgress, done, proLocked }

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
            final streak = ProgramEngine.currentStreak(
              progress: app.dayProgress,
              now: now,
            );
            final proLocked = ProgramEngine.isProLocked(
              day: displayDay,
              isPro: isPro,
            );
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
            final showEvening = now.hour >= 18 &&
                progress?.completedAt != null &&
                !eveningDone;
            final name = app.profile?.name;
            final greeting = name == null || name.isEmpty
                ? loc.v3GreetingHello
                : loc.v3GreetingNamed(_daypart(loc, now), name);

            return Scaffold(
              key: const Key('v3_today_screen'),
              backgroundColor: AppDesignConstants.darkBackground,
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const Key('v3_today_settings'),
                          onPressed: () => context.push(V3Routes.settings),
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
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(loc.v3DayOf(displayDay, 30)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: displayDay / 30,
                        minHeight: 6,
                        backgroundColor: AppDesignConstants.darkBorder,
                        color: AppDesignConstants.brandGreen,
                      ),
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
                        lessonTitle: dayContent.lesson.title.resolve(locale),
                        minutes: loc.v3AboutMinutes(10),
                        state: hero,
                        onPrimary: () {
                          if (hero == TodayHeroState.proLocked) {
                            context.push(
                              '${V3Routes.paywall}?source=locked_day',
                            );
                          } else {
                            context.push(V3Routes.sessionPath(displayDay));
                          }
                        },
                        onReview: () =>
                            context.push(V3Routes.sessionPath(displayDay)),
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
                    const SizedBox(height: 16),
                    OutlinedButton(
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
                    if (showEvening) ...[
                      const SizedBox(height: 16),
                      _EveningCard(
                        onTap: () => showEveningCheckInSheet(
                          context,
                          reflection: dayContent?.reflection.resolve(locale) ??
                              '',
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _ClarityCard(
                      score: latestScore,
                      nextDay: nextCheck,
                    ),
                  ],
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

class _EveningCard extends StatelessWidget {
  const _EveningCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Material(
      color: AppDesignConstants.darkSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('v3_today_evening'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            loc.v3EveningCard,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
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
