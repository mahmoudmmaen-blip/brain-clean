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
import '../session/input_forms.dart';
import '../session/practice_controls.dart';

class V3ExerciseDetailScreen extends ConsumerStatefulWidget {
  const V3ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<V3ExerciseDetailScreen> createState() =>
      _V3ExerciseDetailScreenState();
}

class _V3ExerciseDetailScreenState
    extends ConsumerState<V3ExerciseDetailScreen> {
  bool _easy = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final isPro = ref.watch(isProUserProvider);
    final contentAsync = ref.watch(v3ContentProvider);

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        final ex = bundle.exercises.byId(widget.exerciseId);
        if (ex == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(loc.v3SessionMissingExercise)),
          );
        }
        if (ex.tier == ExerciseTier.pro && !isPro) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('${V3Routes.paywall}?source=tool');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          key: Key('v3_exercise_detail_${ex.id}'),
          backgroundColor: AppDesignConstants.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(ex.title.resolve(locale)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                Text(
                  ex.why.resolve(locale),
                  style: const TextStyle(
                    color: AppDesignConstants.darkOnSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.v3EasyToggle),
                  value: _easy,
                  onChanged: (v) => setState(() => _easy = v),
                ),
                if (_easy)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      ex.easy.resolve(locale),
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                if (!_done) ...[
                  PracticeModeControl(
                    exercise: ex,
                    onComplete: () {
                      if (ex.input == null) {
                        setState(() => _done = true);
                      }
                    },
                  ),
                  if (ex.input != null) ...[
                    const SizedBox(height: 16),
                    PracticeInputForm(
                      inputKey: ex.input!,
                      onSaved: () => setState(() => _done = true),
                    ),
                  ],
                ] else ...[
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppDesignConstants.brandGreen,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesignConstants.brandGreen,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(loc.v3ToolsExerciseDone),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
