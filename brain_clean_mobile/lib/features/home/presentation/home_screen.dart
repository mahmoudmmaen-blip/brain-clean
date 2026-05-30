import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../accountability/accountability_box_modal.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../dashboard/presentation/pro_gated_seven_day_chart.dart';
import '../../pro/pro_gate.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import 'widgets/distraction_safeguard_button.dart';
import 'widgets/global_progress_tracker.dart';
import 'widgets/home_streak_timer_grid.dart';
import 'home_streak_provider.dart';

const homeDiagnosticTileKey = Key('home_diagnostic_tile');
const homeCognitiveHubTileKey = Key('home_cognitive_hub_tile');
const homeRecoveryTileKey = Key('home_recovery_tile');
const homeDetoxTileKey = Key('home_detox_tile');
const homeAccountabilityButtonKey = Key('home_accountability_button');
const homeEmotionWheelKey = Key('home_emotion_wheel_entry');
const homeSingleTaskKey = Key('home_single_task_entry');
const homeDelayedGratificationKey = Key('home_delayed_gratification_entry');
const homeSilenceChallengeKey = Key('home_silence_challenge_entry');
const homeCognitiveTestKey = Key('home_cognitive_test_entry');
const homeSettingsButtonKey = Key('home_settings_button');
const homeProfileButtonKey = Key('home_profile_button');
const homeQuickActionsKey = Key('home_quick_actions_row');

/// Definitive app entry after splash hydration.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(bcScoreSessionProvider);
    final recoveryAsync = ref.watch(recoveryProtocolControllerProvider);
    final isPro = ref.watch(isProUserProvider);

    final bcScore = session?.bcScore ?? 0;
    final streakDays = ref.watch(homeStreakSnapshotProvider).days;
    final challengeProgress = recoveryAsync.maybeWhen(
      data: (state) => state.progressRatio,
      orElse: () => 0.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.homeTitle),
        actions: [
          IconButton(
            key: homeProfileButtonKey,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            key: homeSettingsButtonKey,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlobalProgressTracker(
              bcScore: bcScore,
              challengeProgress: challengeProgress,
              hasSession: session != null,
            ),
            const SizedBox(height: 16),
            const HomeStreakTimerGrid(),
            const SizedBox(height: 16),
            const ProGatedSevenDayChart(),
            const SizedBox(height: 16),
            SizedBox(
              key: homeQuickActionsKey,
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickActionCard(
                    key: homeEmotionWheelKey,
                    icon: Icons.psychology_outlined,
                    iconColor: const Color(0xFF8B949E),
                    label: loc.homeQuickEmotion,
                    proGated: !isPro,
                    proBadge: loc.proBadgeLabel,
                    onTap: () => navigateWithProGate(
                      context,
                      ref,
                      AppRoutes.emotionWheel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    key: homeSilenceChallengeKey,
                    icon: Icons.volume_off_outlined,
                    iconColor: const Color(0xFF8B949E),
                    label: loc.homeQuickSilence,
                    proGated: !isPro,
                    proBadge: loc.proBadgeLabel,
                    onTap: () => navigateSilenceWithProGate(
                      context,
                      ref,
                      streakDays,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    key: homeSingleTaskKey,
                    icon: Icons.track_changes,
                    iconColor: const Color(0xFF1D9E75),
                    label: loc.homeQuickSingleTask,
                    onTap: () => context.push(AppRoutes.singleTask),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    key: homeDelayedGratificationKey,
                    icon: Icons.hourglass_top,
                    iconColor: const Color(0xFFF59E0B),
                    label: loc.homeQuickDelayedGrat,
                    onTap: () => context.push(AppRoutes.delayedGratification),
                  ),
                  const SizedBox(width: 10),
                  _QuickActionCard(
                    key: homeCognitiveTestKey,
                    icon: Icons.science_outlined,
                    iconColor: const Color(0xFF3B82F6),
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
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF2D1216),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFEF4444), width: 0.5),
              ),
              child: ListTile(
                key: homeAccountabilityButtonKey,
                leading: const Icon(Icons.gavel_outlined, color: Color(0xFFEF4444)),
                title: Text(
                  loc.homeAccountabilityBox,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_left, color: Color(0xFF8B949E)),
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
            const SizedBox(height: 12),
            const DistractionSafeguardButton(),
            if (session != null) ...[
              const SizedBox(height: 16),
              BcScoreBreakdown.fromSession(session: session),
            ] else ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    loc.homeEmptyDiagnosticPrompt,
                    textAlign: TextAlign.center,
                    style: context.arabicBodyStyle.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _NavTile(
              key: homeDiagnosticTileKey,
              icon: Icons.analytics_outlined,
              title: loc.homeOpenDiagnostic,
              subtitle: loc.homeOpenDiagnosticSubtitle,
              onTap: () => context.push(AppRoutes.diagnostic),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeCognitiveHubTileKey,
              icon: Icons.visibility_outlined,
              title: loc.homeOpenCognitiveHub,
              subtitle: loc.homeOpenCognitiveHubSubtitle,
              onTap: () => context.push(AppRoutes.cognitiveHub),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeRecoveryTileKey,
              icon: Icons.grid_view_rounded,
              title: loc.dashboardOpenRecoveryGrid,
              subtitle: loc.dashboardOpenRecoveryGridSubtitle,
              onTap: () => context.push(AppRoutes.recovery),
            ),
            const SizedBox(height: 12),
            _NavTile(
              key: homeDetoxTileKey,
              icon: Icons.spa_outlined,
              title: loc.dashboardOpenDetoxCheckIn,
              subtitle: loc.dashboardOpenDetoxCheckInSubtitle,
              onTap: () => context.push(AppRoutes.detox),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.dashboard),
              child: Text(loc.homeOpenFullDashboard),
            ),
          ],
        ),
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
    return SizedBox(
      width: 140,
      height: 90,
      child: Material(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 28, color: iconColor),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE6EDF3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (proGated)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
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
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
