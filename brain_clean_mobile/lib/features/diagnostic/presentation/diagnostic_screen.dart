import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/brain_rot_questionnaire_snapshot.dart';
import '../domain/diagnostic_session.dart';
import 'diagnostic_controller.dart';
import 'diagnostic_session_flow_provider.dart';
import 'widgets/bc_score_breakdown.dart';
import 'widgets/bc_score_hero_card.dart';
import 'widgets/brain_rot_questionnaire_view.dart';
import 'widgets/brain_rot_scoring_loading_overlay.dart';
import 'widgets/brain_rot_score_dashboard.dart';
import 'widgets/diagnostic_metric_slider.dart';

/// Full diagnostic flow — questionnaire, results, and BHI sliders.
///
/// Live state is always [DiagnosticSession.inProgress] via
/// [diagnosticLiveSessionProvider].
class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final asyncMetrics = ref.watch(diagnosticControllerProvider);
    final session = ref.watch(diagnosticLiveSessionProvider);

    return Scaffold(
      backgroundColor: context.isLightTheme
          ? AppDesignConstants.lightBackground
          : AppDesignConstants.darkBackground,
      appBar: AppBar(
        title: Text(_titleForPhase(loc, session.questionnairePhase)),
        actions: [
          if (asyncMetrics.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: asyncMetrics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _DiagnosticErrorView(
            message: loc.diagnosticSyncError,
            onRetry: () =>
                ref.read(diagnosticControllerProvider.notifier).submitDiagnostic(),
          ),
          data: (_) => _InProgressSessionBody(session: session),
        ),
      ),
    );
  }

  static String _titleForPhase(
    AppLocalizations loc,
    BrainRotFlowPhase phase,
  ) =>
      phase == BrainRotFlowPhase.bhiSliders
          ? loc.diagnosticBhiTitle
          : loc.diagnosticBrainRotTitle;
}

/// Renders the active [DiagnosticSession.inProgress] phase with animated handoff.
class _InProgressSessionBody extends ConsumerWidget {
  const _InProgressSessionBody({required this.session});

  final DiagnosticSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = session.questionnairePhase;

    final enteringResults =
        phase == BrainRotFlowPhase.results &&
            !session.questionnaire.pendingResultsTransition;
    final scoringOverlayVisible =
        session.questionnaire.pendingResultsTransition;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: enteringResults
              ? const Duration(milliseconds: 520)
              : const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slideBegin = enteringResults
                ? const Offset(0, 0.12)
                : const Offset(0, 0.06);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: slideBegin,
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: switch (phase) {
            BrainRotFlowPhase.questions => BrainRotQuestionnaireView(
              key: const ValueKey('brain_rot_questions'),
              session: session,
            ),
            BrainRotFlowPhase.results => _BrainRotResultsPhase(
              key: ValueKey(
                'brain_rot_results_${session.brainRotScore}_${session.brainRotBand?.name}',
              ),
              session: session,
            ),
            BrainRotFlowPhase.bhiSliders => _BhiSlidersPhase(
              key: ValueKey(
                'bhi_${session.bcScore.round()}',
              ),
              session: session,
            ),
          },
        ),
        BrainRotScoringLoadingOverlay(visible: scoringOverlayVisible),
      ],
    );
  }
}

class _BrainRotResultsPhase extends ConsumerWidget {
  const _BrainRotResultsPhase({
    super.key,
    required this.session,
  });

  final DiagnosticSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final flow = ref.read(diagnosticSessionFlowProvider.notifier);
    final interpretation = session.brainRot;

    if (interpretation == null) {
      return Center(
        child: Text(
          loc.diagnosticBrainRotIncomplete,
          style: context.arabicBodyStyle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDesignConstants.radiusCard + 2),
      child: BrainRotScoreDashboard(
        interpretation: interpretation,
        onContinue: flow.continueToBhiSliders,
        onReviewAnswers: () => flow.goToQuestion(0),
      ),
    );
  }
}

class _BhiSlidersPhase extends ConsumerWidget {
  const _BhiSlidersPhase({
    super.key,
    required this.session,
  });

  final DiagnosticSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final asyncMetrics = ref.watch(diagnosticControllerProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);
    final evaluation = session.pillarEvaluation;
    final metrics = session.metrics;
    final scoreKey = ValueKey<int>(session.bcScore.round());

    return ListView(
      padding: const EdgeInsets.all(AppDesignConstants.radiusCard + 2),
      children: [
        RepaintBoundary(
          child: BcScoreHeroCard.fromSession(
            key: scoreKey,
            session: session,
            subtitle: loc.diagnosticLiveSubtitle,
          ),
        ),
        RepaintBoundary(
          child: BcScoreBreakdown.fromSession(
            key: ValueKey<String>('breakdown_$scoreKey'),
            session: session,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.diagnosticInstructions,
          textAlign: TextAlign.center,
          style: context.arabicLabelStyle,
        ),
        const SizedBox(height: 16),
        DiagnosticMetricSlider(
          code: 'S1',
          label: loc.diagnosticSleepQuality,
          value: metrics.sleepQuality,
          onChanged: controller.updateSleepQuality,
        ),
        DiagnosticMetricSlider(
          code: 'A2',
          label: loc.diagnosticSustainedAttention,
          value: metrics.sustainedAttention,
          onChanged: controller.updateSustainedAttention,
        ),
        DiagnosticMetricSlider(
          code: 'F3',
          label: loc.diagnosticFragmentation,
          value: metrics.fragmentation,
          onChanged: controller.updateFragmentation,
        ),
        DiagnosticMetricSlider(
          code: 'D4',
          label: loc.diagnosticDopamineSeeking,
          value: metrics.dopamineSeeking,
          onChanged: controller.updateDopamineSeeking,
        ),
        DiagnosticMetricSlider(
          code: 'T5',
          label: loc.diagnosticTaskSwitching,
          value: metrics.taskSwitching,
          onChanged: controller.updateTaskSwitching,
        ),
        DiagnosticMetricSlider(
          code: 'B6',
          label: loc.diagnosticBurnout,
          value: metrics.burnout,
          onChanged: controller.updateBurnout,
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(
              AppDesignConstants.minTouchTarget + 4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDesignConstants.radiusButton,
              ),
            ),
          ),
          onPressed:
              asyncMetrics.isLoading ? null : controller.submitDiagnostic,
          child: asyncMetrics.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(loc.diagnosticStart),
        ),
      ],
    );
  }
}

class _DiagnosticErrorView extends StatelessWidget {
  const _DiagnosticErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.arabicBodyStyle,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.sync),
              label: Text(loc.detoxRetry),
            ),
          ],
        ),
      ),
    );
  }
}
