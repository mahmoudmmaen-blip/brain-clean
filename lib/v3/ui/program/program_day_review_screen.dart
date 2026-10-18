import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../data/user_inputs.dart';

/// Read-only review of a completed program day (`/program/day/:n`).
class V3ProgramDayReviewScreen extends ConsumerWidget {
  const V3ProgramDayReviewScreen({super.key, required this.day});

  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final contentAsync = ref.watch(v3ContentProvider);
    final appAsync = ref.watch(v3AppStateProvider);

    return Scaffold(
      key: const Key('v3_program_day_review'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        title: Text(loc.v3ProgramDayReviewTitle(day)),
        backgroundColor: AppDesignConstants.darkBackground,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (bundle) {
          final dayContent = bundle.program.dayByNumber(day);
          if (dayContent == null) {
            return Center(child: Text(loc.v3SessionMissingDay));
          }
          final exercise = bundle.exercises.byId(dayContent.practiceId);
          return appAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (app) {
              final lesson = dayContent.lesson;
              final inputLines = exercise?.input == null
                  ? const <String>[]
                  : _savedInputLines(
                      inputKey: exercise!.input!,
                      inputs: app.userInputs,
                      loc: loc,
                    );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    key: const Key('v3_program_review_lesson_title'),
                    lesson.title.resolve(locale),
                    style: const TextStyle(
                      fontSize: AppDesignConstants.typeH2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final p in lesson.body.resolve(locale)) ...[
                    Text(
                      p,
                      style: const TextStyle(
                        height: AppDesignConstants.arabicBodyLineHeight,
                        color: AppDesignConstants.darkOnSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    key: const Key('v3_program_review_key_idea'),
                    lesson.key.resolve(locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppDesignConstants.brandGreen,
                      height: AppDesignConstants.arabicBodyLineHeight,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (exercise != null) ...[
                    Text(
                      key: const Key('v3_program_review_practice_title'),
                      exercise.title.resolve(locale),
                      style: const TextStyle(
                        fontSize: AppDesignConstants.typeH3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final step in exercise.steps.resolve(locale)) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  height:
                                      AppDesignConstants.arabicBodyLineHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  if (inputLines.isNotEmpty)
                    KeyedSubtree(
                      key: const Key('v3_program_review_saved_input'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            loc.v3ProgramReviewYourInputs,
                            style: const TextStyle(
                              fontSize: AppDesignConstants.typeH3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final line in inputLines)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                line,
                                style: const TextStyle(
                                  height:
                                      AppDesignConstants.arabicBodyLineHeight,
                                  color:
                                      AppDesignConstants.darkOnSurfaceMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

List<String> _savedInputLines({
  required String inputKey,
  required UserInputs inputs,
  required AppLocalizations loc,
}) {
  switch (inputKey) {
    case 'screen_audit':
      final a = inputs.screenAudit;
      if (a == null) return const [];
      final lines = <String>[];
      if (a.hours != null) lines.add('${loc.v3InputHours}: ${a.hours}');
      for (var i = 0; i < a.apps.length; i++) {
        lines.add('${loc.v3InputApp(i + 1)}: ${a.apps[i]}');
      }
      if (a.pickups != null) lines.add('${loc.v3InputPickups}: ${a.pickups}');
      return lines;
    case 'trigger_pick':
      return inputs.triggers;
    case 'why_statement':
      return inputs.whyStatement == null || inputs.whyStatement!.isEmpty
          ? const []
          : [inputs.whyStatement!];
    case 'replacement_list':
      final r = inputs.replacements;
      return [
        ...r.minutes5.map((e) => '5: $e'),
        ...r.minutes15.map((e) => '15: $e'),
        ...r.minutes60.map((e) => '60: $e'),
      ];
    case 'if_then':
      return inputs.ifThen
          .map((p) => '${loc.v3InputIf} ${p.ifText} · ${loc.v3InputThen} ${p.thenText}')
          .toList(growable: false);
    case 'relapse_plan':
      return inputs.relapsePlan == null || inputs.relapsePlan!.isEmpty
          ? const []
          : [inputs.relapsePlan!];
    case 'identity_statement':
      return inputs.identity == null || inputs.identity!.isEmpty
          ? const []
          : [inputs.identity!];
    case 'maintenance_rules':
      return inputs.rules;
    case 'future_letter':
      return inputs.futureLetter == null || inputs.futureLetter!.isEmpty
          ? const []
          : [inputs.futureLetter!];
    default:
      return const [];
  }
}
