import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import '../../accountability/accountability_box_modal.dart';
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

/// Definitive app entry after splash hydration.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(bcScoreSessionProvider);
    final recoveryAsync = ref.watch(recoveryProtocolControllerProvider);

    final bcScore = session?.bcScore ?? 0;
    final streakDays = ref.watch(homeStreakSnapshotProvider).days;
    final challengeProgress = recoveryAsync.maybeWhen(
      data: (state) => state.progressRatio,
      orElse: () => 0.0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(loc.homeTitle)),
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
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF161B22),
              child: ListTile(
                key: homeEmotionWheelKey,
                leading: const Icon(
                  Icons.psychology_outlined,
                  color: Color(0xFF8B949E),
                ),
                title: const Text(
                  'كيف تشعر الآن؟ 💭',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8B949E),
                ),
                onTap: () => context.push(AppRoutes.emotionWheel),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF161B22),
              child: ListTile(
                key: homeSingleTaskKey,
                leading: const Icon(
                  Icons.track_changes,
                  color: Color(0xFF1D9E75),
                ),
                title: const Text(
                  'قوة التركيز 🎯',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8B949E),
                ),
                onTap: () => context.push(AppRoutes.singleTask),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF161B22),
              child: ListTile(
                key: homeDelayedGratificationKey,
                leading: const Icon(
                  Icons.hourglass_top,
                  color: Color(0xFFF59E0B),
                ),
                title: const Text(
                  'تأخير الإشباع ⏳',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8B949E),
                ),
                onTap: () => context.push(AppRoutes.delayedGratification),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF161B22),
              child: ListTile(
                leading: const Icon(
                  Icons.volume_off_outlined,
                  color: Color(0xFF8B949E),
                ),
                title: const Text(
                  'تحدي الصمت 🤫',
                  style: TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF8B949E),
                ),
                onTap: () => context.push(
                  '/silence-challenge/$streakDays',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const DistractionSafeguardButton(),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: homeAccountabilityButtonKey,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AccountabilityBoxModal(),
                );
              },
              icon: const Icon(Icons.gavel_outlined),
              label: Text(loc.homeOpenAccountability),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
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
