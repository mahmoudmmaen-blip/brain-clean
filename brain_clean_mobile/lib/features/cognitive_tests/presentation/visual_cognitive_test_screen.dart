import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/cognitive_test_result.dart';

/// Placeholder for the Visual Cognitive Image Test.
///
/// Results will feed [CognitiveTestScorer] → [BhiPillarFrozenSnapshot].
class VisualCognitiveTestScreen extends StatelessWidget {
  const VisualCognitiveTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.cognitiveVisualTestTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.image_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              loc.cognitivePlaceholderBody,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                final stub = CognitiveTestResult(
                  testId: 'visual_attention_v1',
                  normalizedScore: 72,
                  completedAt: DateTime.now(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.cognitivePlaceholderRecorded(stub.normalizedScore.round()),
                    ),
                  ),
                );
                context.pop();
              },
              child: Text(loc.cognitivePlaceholderComplete),
            ),
          ],
        ),
      ),
    );
  }
}
