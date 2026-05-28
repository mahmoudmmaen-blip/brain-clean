import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/diagnostic_metrics.dart';
import '../domain/diagnostic_model.dart';
import 'brain_rot_localization.dart';
import 'brain_rot_questionnaire_controller.dart';
import 'bc_score_provider.dart';
import 'diagnostic_controller.dart';
import 'widgets/bc_score_breakdown.dart';
import 'widgets/bc_score_hero_card.dart';
import 'widgets/brain_rot_question_page.dart';
import 'widgets/brain_rot_score_dashboard.dart';
import 'widgets/diagnostic_metric_slider.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final asyncMetrics = ref.watch(diagnosticControllerProvider);
    final flow = ref.watch(brainRotQuestionnaireProvider);
    final flowNotifier = ref.read(brainRotQuestionnaireProvider.notifier);
    final bhiLive = ref.watch(bcScoreLiveProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);
    final result = flowNotifier.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          flow.phase == BrainRotFlowPhase.bhiSliders
              ? loc.diagnosticBhiTitle
              : loc.diagnosticBrainRotTitle,
        ),
        actions: [
          if (asyncMetrics.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
            onRetry: controller.submitDiagnostic,
          ),
          data: (metrics) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _buildPhase(
              context,
              ref,
              key: ValueKey(flow.phase),
              phase: flow.phase,
              flow: flow,
              flowNotifier: flowNotifier,
              metrics: metrics,
              bhiLive: bhiLive,
              result: result,
              asyncMetricsLoading: asyncMetrics.isLoading,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
    required BrainRotFlowPhase phase,
    required BrainRotQuestionnaireState flow,
    required BrainRotQuestionnaire flowNotifier,
    required DiagnosticMetrics metrics,
    required DiagnosticModel bhiLive,
    required BrainRotInterpretation? result,
    required bool asyncMetricsLoading,
    required DiagnosticController controller,
  }) {
    final loc = AppLocalizations.of(context)!;

    switch (phase) {
      case BrainRotFlowPhase.questions:
        final index = flow.currentIndex;
        return Padding(
          key: key,
          padding: const EdgeInsets.all(20),
          child: BrainRotQuestionPage(
            questionIndex: index,
            questionText: brainRotQuestionFor(context, loc, index),
            onAnswer: (yes) => flowNotifier.answerQuestion(index, yes),
            onBack: index > 0 ? () => flowNotifier.goToQuestion(index - 1) : null,
          ),
        );
      case BrainRotFlowPhase.results:
        if (result == null) {
          return Center(key: key, child: Text(loc.diagnosticBrainRotIncomplete));
        }
        return Padding(
          key: key,
          padding: const EdgeInsets.all(16),
          child: BrainRotScoreDashboard(
            interpretation: result,
            onContinue: flowNotifier.continueToBhiSliders,
            onReviewAnswers: () => flowNotifier.goToQuestion(0),
          ),
        );
      case BrainRotFlowPhase.bhiSliders:
        return ListView(
          key: key,
          padding: const EdgeInsets.all(16),
          children: [
            BcScoreHeroCard(
              score: bhiLive.bcScore,
              subtitle: loc.diagnosticLiveSubtitle,
            ),
            BcScoreBreakdown(model: bhiLive),
            const SizedBox(height: 8),
            Text(
              loc.diagnosticInstructions,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textMuted,
                  ),
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
              onPressed: asyncMetricsLoading ? null : controller.submitDiagnostic,
              child: asyncMetricsLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(loc.diagnosticStart),
            ),
          ],
        );
    }
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
            Text(message, textAlign: TextAlign.center),
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
