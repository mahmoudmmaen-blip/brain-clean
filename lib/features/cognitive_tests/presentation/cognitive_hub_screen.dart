import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

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
            color: AppColors.card,
            child: ListTile(
              leading: const Icon(Icons.image_search_outlined,
                  color: AppColors.primary),
              title: Text(loc.cognitiveVisualTestTitle),
              subtitle: Text(loc.cognitiveVisualTestSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.cognitiveVisual),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.card,
            child: ListTile(
              leading:
                  const Icon(Icons.memory_outlined, color: AppColors.primary),
              title: Text(loc.cognitiveMemoryGameTitle),
              subtitle: Text(loc.cognitiveMemoryGameSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.cognitiveMemory),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: const Icon(Icons.psychology_outlined,
                  color: AppColors.primary),
              title: Text(loc.iqTestTitle),
              subtitle: Text(loc.iqTestSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.v2IqTest),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: const Icon(Icons.smartphone_outlined,
                  color: AppColors.primary),
              title: Text(loc.digitalBrainRotTestTitle),
              subtitle: Text(loc.digitalBrainRotTestSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.v2DigitalBrainRotTest),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.card,
            child: ListTile(
              leading:
                  const Icon(Icons.apps_outlined, color: AppColors.primary),
              title: Text(loc.testsCatalogTitle),
              subtitle: Text(loc.testsCatalogSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.v2Tests),
            ),
          ),
        ],
      ),
    );
  }
}