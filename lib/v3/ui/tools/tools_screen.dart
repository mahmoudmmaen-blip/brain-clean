import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../content/content_repository.dart';
import '../../content/exercises_content.dart';
import '../../routing/v3_routes.dart';
import '../shell/v3_tab_placeholder.dart';
import 'twenty_twenty_tile.dart';

class V3ToolsScreen extends ConsumerStatefulWidget {
  const V3ToolsScreen({super.key});

  @override
  ConsumerState<V3ToolsScreen> createState() => _V3ToolsScreenState();
}

class _V3ToolsScreenState extends ConsumerState<V3ToolsScreen> {
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final isPro = ref.watch(isProUserProvider);
    final contentAsync = ref.watch(v3ContentProvider);

    return Scaffold(
      key: V3ShellKeys.toolsTab,
      backgroundColor: AppDesignConstants.darkBackground,
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (bundle) {
          final exercises = bundle.exercises.exercises;
          final categories = bundle.exercises.categories;
          final filtered = _categoryFilter == null
              ? exercises
              : exercises
                  .where((e) => e.category == _categoryFilter)
                  .toList(growable: false);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                Text(
                  loc.v3TabTools,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(loc.v3ToolsFocusTitle),
                const SizedBox(height: 8),
                Card(
                  key: const Key('v3_tools_focus_card'),
                  child: ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(loc.v3ToolsFocusTitle),
                    subtitle: Text(loc.v3ToolsFocusHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(V3Routes.toolsFocus),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(loc.v3ToolsBreathingTitle),
                const SizedBox(height: 8),
                Card(
                  key: const Key('v3_tools_breath_double'),
                  child: ListTile(
                    leading: const Icon(Icons.air),
                    title: Text(loc.v3ToolsDoubleSigh),
                    trailing: _Badge(free: true, loc: loc),
                    onTap: () => context.push(
                      V3Routes.toolsBreathingPath('double_sigh'),
                    ),
                  ),
                ),
                Card(
                  key: const Key('v3_tools_breath_46'),
                  child: ListTile(
                    leading: const Icon(Icons.spa_outlined),
                    title: Text(loc.v3ToolsBreath46),
                    trailing: _Badge(free: false, loc: loc),
                    onTap: () {
                      if (!isPro) {
                        context.push('${V3Routes.paywall}?source=tool');
                        return;
                      }
                      context.push(V3Routes.toolsBreathingPath('breath_46'));
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(loc.v3ToolsExercisesTitle),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        key: const Key('v3_tools_cat_all'),
                        label: Text(loc.v3ToolsAllCategories),
                        selected: _categoryFilter == null,
                        onSelected: (_) =>
                            setState(() => _categoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      for (final entry in categories.entries) ...[
                        FilterChip(
                          key: Key('v3_tools_cat_${entry.key}'),
                          label: Text(entry.value.resolve(locale)),
                          selected: _categoryFilter == entry.key,
                          onSelected: (_) =>
                              setState(() => _categoryFilter = entry.key),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                for (final ex in filtered)
                  _ExerciseTile(
                    exercise: ex,
                    locale: locale,
                    isPro: isPro,
                    loc: loc,
                  ),
                const SizedBox(height: 20),
                _SectionTitle(loc.v3ToolsTwentyTitle),
                const SizedBox(height: 8),
                const TwentyTwentyTile(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.free, required this.loc});
  final bool free;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: free
            ? AppDesignConstants.brandGreen.withValues(alpha: 0.2)
            : const Color(0xFFD4A017).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        free ? loc.v3ToolsFreeBadge : loc.v3ToolsProBadge,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: free ? AppDesignConstants.brandGreen : const Color(0xFFD4A017),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.locale,
    required this.isPro,
    required this.loc,
  });

  final ExerciseContent exercise;
  final String locale;
  final bool isPro;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final locked = exercise.tier == ExerciseTier.pro && !isPro;
    return Card(
      key: Key('v3_tools_ex_${exercise.id}'),
      child: ListTile(
        title: Text(exercise.title.resolve(locale)),
        subtitle: Text(
          '${exercise.minutes} · ${exercise.category}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Badge(free: exercise.tier == ExerciseTier.free, loc: loc),
            const SizedBox(width: 4),
            Icon(locked ? Icons.lock_outline : Icons.chevron_right),
          ],
        ),
        onTap: () {
          if (locked) {
            context.push('${V3Routes.paywall}?source=tool');
            return;
          }
          context.push(V3Routes.toolsExercisePath(exercise.id));
        },
      ),
    );
  }
}
