import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../application/daily_program_provider.dart';
import '../domain/daily_program_service.dart';
import '../domain/daily_program_state.dart';
import '../domain/daily_step_status.dart';

const dayEndScreenKey = Key('day_end_screen');
const dayEndFinishButtonKey = Key('day_end_finish_button');

/// Calm day-closing ritual — summary, optional reflection, gentle exit.
class DayEndScreen extends ConsumerStatefulWidget {
  const DayEndScreen({super.key});

  @override
  ConsumerState<DayEndScreen> createState() => _DayEndScreenState();
}

class _DayEndScreenState extends ConsumerState<DayEndScreen> {
  final _reflectionController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  String _reflectionQuestion(AppLocalizations loc, DateTime date) {
    return switch (DailyProgramService.reflectionQuestionIndex(date)) {
      0 => loc.dayEndReflection0,
      1 => loc.dayEndReflection1,
      2 => loc.dayEndReflection2,
      _ => loc.dayEndReflection3,
    };
  }

  String _stepStatusIcon(DailyStepStatus status) {
    return switch (status) {
      DailyStepStatus.done => '✅',
      DailyStepStatus.skipped ||
      DailyStepStatus.locked ||
      DailyStepStatus.current =>
        '⬜',
    };
  }

  Future<void> _finishDay() async {
    if (_busy) return;
    setState(() => _busy = true);
    final note = _reflectionController.text;
    await ref
        .read(dailyProgramProvider.notifier)
        .completeDayEnd(reflectionNote: note);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(dailyProgramProvider);

    return Scaffold(
      key: dayEndScreenKey,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(loc.dailyProgramLoadError)),
        data: (state) => _DayEndBody(
          state: state,
          reflectionController: _reflectionController,
          reflectionQuestion: _reflectionQuestion(loc, state.date),
          stepStatusIcon: _stepStatusIcon,
          busy: _busy,
          onFinish: _finishDay,
        ),
      ),
    );
  }
}

class _DayEndBody extends StatelessWidget {
  const _DayEndBody({
    required this.state,
    required this.reflectionController,
    required this.reflectionQuestion,
    required this.stepStatusIcon,
    required this.busy,
    required this.onFinish,
  });

  final DailyProgramState state;
  final TextEditingController reflectionController;
  final String reflectionQuestion;
  final String Function(DailyStepStatus status) stepStatusIcon;
  final bool busy;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final languageCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text(
            '🏁',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            loc.dayEndTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.dayEndSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.dayEndSummaryTitle,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < state.steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        DailyProgramService.getStepEmoji(state.steps[i].step),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DailyProgramService.getStepTitle(
                            state.steps[i].step,
                            languageCode: languageCode,
                          ),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        stepStatusIcon(state.steps[i].status),
                        style: TextStyle(
                          color: state.steps[i].status == DailyStepStatus.done
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  reflectionQuestion,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reflectionController,
                  maxLines: 3,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: reflectionQuestion,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Text(
              loc.dayEndClosingMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: dayEndFinishButtonKey,
            onPressed: busy ? null : onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    loc.dayEndFinishButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
