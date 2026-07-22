import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../../core/application/app_preferences_provider.dart';

import '../../../core/constants/app_routes.dart';

import '../../../core/l10n/app_localizations.dart';

import '../../../core/presentation/async_state_views.dart';

import '../../../core/presentation/language_toggle_button.dart';

import '../../../shared/widgets/glass_card.dart';

import '../widgets/daily_quote_card.dart';

import '../../accountability/accountability_box_modal.dart';

import '../../diagnostic/presentation/bc_score_provider.dart';

import '../../diagnostic/domain/diagnostic_session.dart';

import '../../pro/application/subscription_service_provider.dart';

import '../../pro/pro_gate.dart';

import '../../recovery/domain/recovery_daily_task.dart';

import '../../recovery/presentation/recovery_protocol_controller.dart';

import '../../worry/presentation/worry_today_entries_provider.dart';

import '../../daily_challenge/presentation/daily_challenge_card.dart';

import '../../daily_program/presentation/daily_program_home_card.dart';

import '../widgets/social_media_usage_home_card.dart';

import 'widgets/global_progress_tracker.dart';

import 'home_streak_provider.dart';



const homeAccountabilityButtonKey = Key('home_accountability_button');

const homeEmotionWheelKey = Key('home_emotion_wheel_entry');

const homeSingleTaskKey = Key('home_single_task_entry');

const homeDelayedGratificationKey = Key('home_delayed_gratification_entry');

const homeSilenceChallengeKey = Key('home_silence_challenge_entry');

const homeCognitiveTestKey = Key('home_cognitive_test_entry');

const homePomodoroKey = Key('home_pomodoro_entry');

const homeGamesKey = Key('home_games_entry');

const homeFocusedThinkingKey = Key('home_focused_thinking_entry');

const homeCrosswordKey = Key('home_crossword_entry');

const homeQuickActionsKey = Key('home_quick_actions_row');



const homeStreakMotivationKey = Key('home_streak_motivation');



String _greetingText(AppLocalizations loc) {

  final hour = TimeOfDay.now().hour;

  if (hour < 12) return loc.homeGreetingMorning;

  if (hour < 18) return loc.homeGreetingAfternoon;

  return loc.homeGreetingEvening;

}



String _heroName(AppLocalizations loc, AppPreferencesState prefs) {

  final stored = prefs.profileDisplayName.trim();

  return stored.isEmpty ? loc.homeHeroName : stored;

}



/// Definitive app entry after splash hydration.

class HomeScreen extends ConsumerWidget {

  const HomeScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final loc = AppLocalizations.of(context)!;

    final session = ref.watch(bcScoreSessionProvider);

    final recoveryAsync = ref.watch(recoveryProtocolControllerProvider);

    final isPro = ref.watch(isProUserProvider);

    final prefs = ref.watch(appPreferencesProvider);

    final streakDays = ref.watch(homeStreakSnapshotProvider).days;

    final challengeProgress = recoveryAsync.maybeWhen(

      data: (state) => state.progressRatio,

      orElse: () => 0.0,

    );



    return Scaffold(

      body: SafeArea(

        child: recoveryAsync.when(

          loading: () => AsyncStateViews.loading(context),

          error: (_, __) => AsyncStateViews.error(context),

          data: (_) => _HomeBody(
                  loc: loc,
                  session: session,
                  isPro: isPro,
                  prefs: prefs,
                  streakDays: streakDays,
                  challengeProgress: challengeProgress,
                ),
        ),
      ),
    );

  }

}



class _HomeBody extends ConsumerWidget {

  const _HomeBody({

    required this.loc,

    required this.session,

    required this.isPro,

    required this.prefs,

    required this.streakDays,

    required this.challengeProgress,

  });



  final AppLocalizations loc;

  final DiagnosticSession? session;

  final bool isPro;

  final AppPreferencesState prefs;

  final int streakDays;

  final double challengeProgress;



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final bcScore = (session?.bcScore ?? 0.0).clamp(0.0, 100.0);

    final colorScheme = Theme.of(context).colorScheme;

    final heroName = _heroName(loc, prefs);



    return ListView(

      padding: const EdgeInsets.all(16),

      children: [

        const DailyProgramHomeCard(),

        const SizedBox(height: 12),

        const SocialMediaUsageHomeCard(),

        const SizedBox(height: 12),

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    _greetingText(loc),

                    style: TextStyle(

                      color: colorScheme.onSurfaceVariant,

                      fontSize: 14,

                    ),

                  ),

                  Text(

                    heroName,

                    style: TextStyle(

                      color: colorScheme.onSurface,

                      fontSize: 24,

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                  Text(

                    loc.homeTitle,

                    style: TextStyle(

                      color: colorScheme.onSurfaceVariant,

                      fontSize: 11,

                    ),

                  ),

                ],

              ),

            ),

            const LanguageToggleButton(),

            IconButton(

              icon: Icon(

                Icons.settings_outlined,

                color: colorScheme.onSurfaceVariant,

              ),

              onPressed: () => context.go(AppRoutes.settings),

            ),

          ],

        ),

        const SizedBox(height: 16),

        IntrinsicHeight(

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Expanded(

                flex: 2,

                child: GlassCard(

                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      Text(

                        streakDays.toString(),

                        style: TextStyle(

                          color: colorScheme.primary,

                          fontSize: 40,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

                      const SizedBox(height: 4),

                      const Icon(

                        Icons.local_fire_department_rounded,

                        color: Color(0xFFFBBF24),

                        size: 20,

                      ),

                      const SizedBox(height: 4),

                      Text(

                        loc.homeStreakLabel,

                        style: TextStyle(

                          color: colorScheme.onSurfaceVariant,

                          fontSize: 12,

                        ),

                      ),

                      const SizedBox(height: 8),

                      _WeekDots(streakDays: streakDays),

                    ],

                  ),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                flex: 3,

                child: GlassCard(

                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      Text(

                        '${bcScore.toInt()}%',

                        style: TextStyle(

                          color: colorScheme.primary,

                          fontSize: 36,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

                      Text(

                        loc.homeBciLabel,

                        style: TextStyle(

                          color: colorScheme.onSurfaceVariant,

                          fontSize: 12,

                        ),

                      ),

                      const SizedBox(height: 8),

                      Row(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          Icon(

                            Icons.trending_up,

                            color: colorScheme.primary,

                            size: 14,

                          ),

                          const SizedBox(width: 4),

                          Text(

                            loc.homeBciTrend,

                            style: TextStyle(

                              color: colorScheme.primary,

                              fontSize: 11,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              ),

            ],

          ),

        ),

        const SizedBox(height: 12),

        const _DailyActivityChips(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DailyChallengeCard(),
        ),

        const SizedBox(height: 12),

        IntrinsicHeight(

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Expanded(

                child: GlassCard(

                  child: InkWell(

                    onTap: () => context.go(AppRoutes.safa),

                    borderRadius: BorderRadius.circular(18),

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const _SafaOrb(size: 44),

                        const SizedBox(height: 8),

                        Text(

                          loc.navTabSafa,

                          style: TextStyle(

                            color: colorScheme.onSurface,

                            fontSize: 14,

                            fontWeight: FontWeight.w600,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Text(

                          loc.homeSafaMessage,

                          style: TextStyle(

                            color: colorScheme.primary,

                            fontSize: 11,

                          ),

                          textAlign: TextAlign.center,

                        ),

                      ],

                    ),

                  ),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: GlassCard(

                  child: InkWell(

                    onTap: () => context.push(AppRoutes.proPaywall),

                    borderRadius: BorderRadius.circular(18),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [

                        Row(

                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [

                            Text(

                              'Pro ★',

                              style: TextStyle(

                                color: const Color(0xFFFBBF24),

                                fontSize: 14,

                                fontWeight: FontWeight.w700,

                              ),

                            ),

                          ],

                        ),

                        const SizedBox(height: 6),

                        Text(

                          loc.homeProFeature,

                          style: TextStyle(

                            color: colorScheme.onSurfaceVariant,

                            fontSize: 11,

                          ),

                        ),

                        const SizedBox(height: 8),

                        Text(

                          loc.proPriceMonthly,

                          style: const TextStyle(

                            color: Color(0xFFFBBF24),

                            fontSize: 16,

                            fontWeight: FontWeight.w700,

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

        const SizedBox(height: 20),

        _QuickActionsRow(

          loc: loc,

          isPro: isPro,

          streakDays: streakDays,

        ),

        const SizedBox(height: 20),

        GlassCard(

          padding: EdgeInsets.zero,

          child: const DailyQuoteCard(),

        ),

        const SizedBox(height: 12),

        GlassCard(

          padding: EdgeInsets.zero,

          child: ListTile(

            key: homeAccountabilityButtonKey,

            leading: Icon(Icons.gavel_outlined, color: colorScheme.error),

            title: Text(

              loc.homeAccountabilityBox,

              style: TextStyle(

                color: colorScheme.onSurface,

                fontWeight: FontWeight.w600,

              ),

            ),

            trailing: Icon(

              Icons.chevron_left,

              color: colorScheme.onSurfaceVariant,

            ),

            onTap: () {

              showModalBottomSheet<void>(

                context: context,

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

                builder: (_) => const AccountabilityBoxModal(),

              );

            },

          ),

        ),

        if (streakDays == 0) ...[

          const SizedBox(height: 12),

          Text(

            loc.homeStreakMotivation,

            key: homeStreakMotivationKey,

            textAlign: TextAlign.center,

            style: TextStyle(

              color: colorScheme.primary,

              fontSize: 14,

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

        IgnorePointer(
          child: Opacity(
            opacity: 0.01,
            child: SizedBox(
              height: 120,
              child: GlobalProgressTracker(
                bcScore: bcScore,
                challengeProgress: challengeProgress,
                hasSession: session != null,
              ),
            ),
          ),
        ),

        const SizedBox(height: 80),

      ],

    );

  }

}



class _WeekDots extends StatelessWidget {

  const _WeekDots({required this.streakDays});



  final int streakDays;



  @override

  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Row(

      mainAxisAlignment: MainAxisAlignment.center,

      children: List.generate(7, (index) {

        final filled = index < (streakDays % 7 == 0 && streakDays > 0

            ? 7

            : streakDays % 7);

        return Container(

          width: 8,

          height: 8,

          margin: const EdgeInsets.symmetric(horizontal: 3),

          decoration: BoxDecoration(

            shape: BoxShape.circle,

            color: filled

                ? colorScheme.primary

                : colorScheme.outline.withOpacity(0.35),

          ),

        );

      }),

    );

  }

}



class _DailyActivityChips extends ConsumerWidget {

  const _DailyActivityChips();



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final loc = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;

    final recovery = ref.watch(recoveryProtocolControllerProvider).valueOrNull;

    final dayIndex = recovery?.currentProtocolDay ?? 1;

    final record = recovery?.dayRecord(dayIndex);

    final worryDone = ref.watch(worryHabitDoneTodayProvider).valueOrNull ?? false;



    final chips = <({String label, bool done, VoidCallback? onTap})>[

      (

        label: loc.homeActivityExercise,

        done: record?.taskCompleted[RecoveryDailyTask.movementTwentyMinutes.index] ??

            false,

        onTap: null,

      ),

      (label: loc.homeActivityWater, done: record?.waterCompleted ?? false, onTap: null),

      (label: loc.homeActivitySleep, done: record?.sleepCompleted ?? false, onTap: null),

      (

        label: loc.homeActivityMovement,

        done: record?.taskCompleted[RecoveryDailyTask.distractionManagement.index] ??

            false,

        onTap: null,

      ),

      (

        label: loc.homeActivityWorryJournal,

        done: worryDone,

        onTap: () => context.push(AppRoutes.worryJournal),

      ),

      (

        label: loc.homeActivityWorryWindow,

        done: worryDone,

        onTap: () => context.push(AppRoutes.worryWindow),

      ),

    ];

    final doneCount = chips.where((c) => c.done).length;



    return GlassCard(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                '$doneCount ${loc.homeActivitiesOf} ${chips.length}',

                style: TextStyle(

                  color: colorScheme.primary,

                  fontSize: 12,

                  fontWeight: FontWeight.w600,

                ),

              ),

              Text(

                loc.homeActivitiesTitle,

                style: TextStyle(

                  color: colorScheme.onSurface,

                  fontSize: 16,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ],

          ),

          const SizedBox(height: 12),

          Wrap(

            spacing: 8,

            runSpacing: 8,

            alignment: WrapAlignment.end,

            children: chips

                .map(

                  (chip) => ActionChip(

                    avatar: Icon(

                      chip.done ? Icons.check_circle : Icons.circle_outlined,

                      size: 18,

                      color: chip.done

                          ? colorScheme.primary

                          : colorScheme.onSurfaceVariant,

                    ),

                    label: Text(chip.label),

                    backgroundColor: colorScheme.surface.withOpacity(0.5),

                    labelStyle: TextStyle(color: colorScheme.onSurface),

                    onPressed: chip.onTap,

                  ),

                )

                .toList(),

          ),

        ],

      ),

    );

  }

}



class _SafaOrb extends StatelessWidget {

  const _SafaOrb({required this.size});



  final double size;



  @override

  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Container(

      width: size,

      height: size,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: colorScheme.primary.withOpacity(0.15),

        boxShadow: [

          BoxShadow(

            color: colorScheme.primary.withOpacity(0.25),

            blurRadius: 16,

            spreadRadius: 2,

          ),

        ],

      ),

      child: Icon(

        Icons.smart_toy,

        color: colorScheme.primary,

        size: size * 0.55,

      ),

    );

  }

}



class _QuickActionsRow extends ConsumerWidget {

  const _QuickActionsRow({

    required this.loc,

    required this.isPro,

    required this.streakDays,

  });



  final AppLocalizations loc;

  final bool isPro;

  final int streakDays;



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final colorScheme = Theme.of(context).colorScheme;



    return SizedBox(

      key: homeQuickActionsKey,

      height: 90,

      child: ListView(

        scrollDirection: Axis.horizontal,

        children: [

          _QuickActionCard(

            key: homeEmotionWheelKey,

            icon: Icons.psychology_outlined,

            iconColor: colorScheme.onSurfaceVariant,

            label: loc.homeQuickEmotion,

            proGated: !isPro,

            proBadge: loc.proBadgeLabel,

            onTap: () => navigateWithProGate(

              context,

              ref,

              AppRoutes.emotionWheel,

            ),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeSilenceChallengeKey,

            icon: Icons.volume_off_outlined,

            iconColor: colorScheme.onSurfaceVariant,

            label: loc.homeQuickSilence,

            proGated: !isPro,

            proBadge: loc.proBadgeLabel,

            onTap: () => navigateSilenceWithProGate(

              context,

              ref,

              streakDays,

            ),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeSingleTaskKey,

            icon: Icons.track_changes,

            iconColor: colorScheme.primary,

            label: loc.homeQuickSingleTask,

            onTap: () => context.push(AppRoutes.singleTask),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homePomodoroKey,

            icon: Icons.timer_outlined,

            iconColor: colorScheme.primary,

            label: loc.homeQuickPomodoro,

            onTap: () => context.push(AppRoutes.pomodoro),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeFocusedThinkingKey,

            icon: Icons.psychology,

            iconColor: colorScheme.primary,

            label: loc.homeQuickFocusedThinking,

            onTap: () => context.push(AppRoutes.focusedThinking),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeCrosswordKey,

            icon: Icons.grid_on_outlined,

            iconColor: colorScheme.primary,

            label: loc.homeQuickCrossword,

            proGated: !isPro,

            proBadge: loc.proBadgeLabel,

            onTap: () => navigateWithProGate(

              context,

              ref,

              AppRoutes.crossword,

            ),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeGamesKey,

            icon: Icons.videogame_asset_outlined,

            iconColor: colorScheme.primary,

            label: loc.homeQuickGames,

            proGated: !isPro,

            proBadge: loc.proBadgeLabel,

            onTap: () => navigateWithProGate(

              context,

              ref,

              AppRoutes.games,

            ),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeDelayedGratificationKey,

            icon: Icons.hourglass_top,

            iconColor: colorScheme.primary,

            label: loc.homeQuickDelayedGrat,

            onTap: () => context.push(AppRoutes.delayedGratification),

          ),

          const SizedBox(width: 12),

          _QuickActionCard(

            key: homeCognitiveTestKey,

            icon: Icons.science_outlined,

            iconColor: colorScheme.primary,

            label: loc.homeQuickCognitiveTest,

            proGated: !isPro,

            proBadge: loc.proBadgeLabel,

            onTap: () => navigateWithProGate(

              context,

              ref,

              AppRoutes.cognitiveTest,

            ),

          ),

        ],

      ),

    );

  }

}



class _QuickActionCard extends StatelessWidget {

  const _QuickActionCard({

    super.key,

    required this.icon,

    required this.iconColor,

    required this.label,

    required this.onTap,

    this.proGated = false,

    this.proBadge = 'Pro',

  });



  final IconData icon;

  final Color iconColor;

  final String label;

  final VoidCallback onTap;

  final bool proGated;

  final String proBadge;



  @override

  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(

      width: 140,

      height: 90,

      child: GlassCard(

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

        borderRadius: 14,

        child: Material(

          color: Colors.transparent,

          child: InkWell(

            onTap: onTap,

            borderRadius: BorderRadius.circular(14),

            child: Stack(

              children: [

                Center(

                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      Icon(icon, size: 28, color: iconColor),

                      const SizedBox(height: 6),

                      Padding(

                        padding: const EdgeInsets.symmetric(horizontal: 4),

                        child: Text(

                          label,

                          textAlign: TextAlign.center,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(

                            fontSize: 12,

                            color: colorScheme.onSurface,

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

                if (proGated)

                  Positioned(

                    top: 0,

                    right: 0,

                    child: Container(

                      padding: const EdgeInsets.symmetric(

                        horizontal: 6,

                        vertical: 2,

                      ),

                      decoration: BoxDecoration(

                        color: colorScheme.primary,

                        borderRadius: BorderRadius.circular(8),

                      ),

                      child: Text(

                        proBadge,

                        style: const TextStyle(

                          fontSize: 9,

                          fontWeight: FontWeight.bold,

                          color: Colors.white,

                        ),

                      ),

                    ),

                  ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}


