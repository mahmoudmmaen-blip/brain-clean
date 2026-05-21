import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'diagnostic_controller.dart';
import 'widgets/diagnostic_metric_slider.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(diagnosticControllerProvider);
    final controller = ref.read(diagnosticControllerProvider.notifier);
    final focusScore = metrics.calculateFocusScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic 6-Point Test'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FocusScorePreview(score: focusScore),
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

class _FocusScorePreview extends StatelessWidget {
  const _FocusScorePreview({required this.score});

  final double score;

  Color get _scoreColor {
    if (score <= 30) return const Color(0xFFEF4444);
    if (score <= 60) return AppTheme.gold;
    if (score <= 85) return AppTheme.success;
    return const Color(0xFF0F6E56);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'BRAIN CLARITY SCORE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${score.round()}%',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: _scoreColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Live focus index (neuro formula)',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
