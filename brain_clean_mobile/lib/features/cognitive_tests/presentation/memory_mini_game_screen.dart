import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/cognitive_test_result.dart';

/// Placeholder for memory sequence mini-games.
class MemoryMiniGameScreen extends StatelessWidget {
  const MemoryMiniGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.cognitiveMemoryGameTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.grid_on_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.secondary,
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
                  testId: 'memory_sequence_v1',
                  normalizedScore: 68,
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
