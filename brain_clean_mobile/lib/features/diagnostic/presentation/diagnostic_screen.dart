import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bc_score_provider.dart';
import 'diagnostic_controller.dart';
import 'widgets/bc_score_breakdown.dart';
import 'widgets/bc_score_hero_card.dart';
import 'widgets/diagnostic_metric_slider.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(diagnosticControllerProvider);
    final bhiLive = ref.watch(bcScoreLiveProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic 6-Point Test'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BcScoreHeroCard(
              score: bhiLive.bcScore,
              subtitle: 'Live · updates on every slider move',
            ),
            BcScoreBreakdown(model: bhiLive),
            const SizedBox(height: 8),
            const Text(
              'Rate each dimension from 1 (low) to 10 (high).',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            DiagnosticMetricSlider(
              code: 'S1',
              label: 'Sleep Quality',
              value: metrics.sleepQuality,
              onChanged: controller.updateSleepQuality,
            ),
            DiagnosticMetricSlider(
              code: 'A2',
              label: 'Sustained Attention',
              value: metrics.sustainedAttention,
              onChanged: controller.updateSustainedAttention,
            ),
            DiagnosticMetricSlider(
              code: 'F3',
              label: 'Fragmentation',
              value: metrics.fragmentation,
              onChanged: controller.updateFragmentation,
            ),
            DiagnosticMetricSlider(
              code: 'D4',
              label: 'Dopamine Seeking',
              value: metrics.dopamineSeeking,
              onChanged: controller.updateDopamineSeeking,
            ),
            DiagnosticMetricSlider(
              code: 'T5',
              label: 'Task Switching',
              value: metrics.taskSwitching,
              onChanged: controller.updateTaskSwitching,
            ),
            DiagnosticMetricSlider(
              code: 'B6',
              label: 'Burnout',
              value: metrics.burnout,
              onChanged: controller.updateBurnout,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => controller.submitDiagnostic(),
              child: const Text('Start Brain Clean'),
            ),
          ],
        ),
      ),
    );
  }
}
