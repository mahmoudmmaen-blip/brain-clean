import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import 'bc_score_provider.dart';
import 'diagnostic_controller.dart';
import 'widgets/bc_score_breakdown.dart';
import 'widgets/bc_score_hero_card.dart';
import 'widgets/diagnostic_metric_slider.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final metrics = ref.watch(diagnosticControllerProvider);
    final bhiLive = ref.watch(bcScoreLiveProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.diagnosticTitle),
      ),
      body: SafeArea(
        child: ListView(
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
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
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
              onPressed: () => controller.submitDiagnostic(),
              child: Text(loc.diagnosticStart),
            ),
          ],
        ),
      ),
    );
  }
}
