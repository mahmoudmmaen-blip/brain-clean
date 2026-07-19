import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';

/// Exercises tab — curated entry points into focus and cognitive tools.
class ExercisesTabScreen extends ConsumerWidget {
  const ExercisesTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.exercisesTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExerciseCard(
            icon: Icons.psychology,
            title: loc.exercisesCardCognitiveHubTitle,
            subtitle: loc.exercisesCardCognitiveHubSubtitle,
            onTap: () => context.push(AppRoutes.cognitiveHub),
          ),
          _ExerciseCard(
            icon: Icons.timer,
            title: loc.exercisesCardPomodoroTitle,
            subtitle: loc.exercisesCardPomodoroSubtitle,
            onTap: () => context.push(AppRoutes.pomodoro),
          ),
          _ExerciseCard(
            icon: Icons.self_improvement,
            title: loc.exercisesCardSukoonTitle,
            subtitle: loc.exercisesCardSukoonSubtitle,
            onTap: () => context.push(AppRoutes.sukoon),
          ),
          _ExerciseCard(
            icon: Icons.air,
            title: loc.exercisesCardBreathingTitle,
            subtitle: loc.exercisesCardBreathingSubtitle,
            onTap: () => context.push(AppRoutes.breathingFriction(50)),
          ),
          _ExerciseCard(
            icon: Icons.grid_on,
            title: loc.exercisesCardGamesTitle,
            subtitle: loc.exercisesCardGamesSubtitle,
            onTap: () => context.push(AppRoutes.games),
          ),
          _ExerciseCard(
            icon: Icons.track_changes,
            title: loc.exercisesCardSingleTaskTitle,
            subtitle: loc.exercisesCardSingleTaskSubtitle,
            onTap: () => context.push(AppRoutes.singleTask),
          ),
          _ExerciseCard(
            icon: Icons.psychology_alt,
            title: loc.exercisesCardDeepThinkingTitle,
            subtitle: loc.exercisesCardDeepThinkingSubtitle,
            onTap: () => context.push(AppRoutes.focusedThinking),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.15),
            child: Icon(icon, color: colorScheme.primary),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
