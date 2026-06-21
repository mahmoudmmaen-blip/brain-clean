import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';

/// Entry hub for visual cognitive tests and memory mini-games.
class CognitiveHubScreen extends StatelessWidget {
  const CognitiveHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.cognitiveHubTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.cognitiveHubSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.image_search_outlined),
              title: Text(loc.cognitiveVisualTestTitle),
              subtitle: Text(loc.cognitiveVisualTestSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.cognitiveVisual),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory_outlined),
              title: Text(loc.cognitiveMemoryGameTitle),
              subtitle: Text(loc.cognitiveMemoryGameSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.cognitiveMemory),
            ),
          ),
        ],
      ),
    );
  }
}
