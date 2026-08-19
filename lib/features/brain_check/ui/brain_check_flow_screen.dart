import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/brain_check_controller.dart';
import '../application/brain_check_controller_provider.dart';
import '../domain/brain_check_item_bank.dart';
import '../domain/brain_check_phase.dart';
import '../domain/brain_check_question.dart';
import 'brain_check_answer_control.dart';

/// CHK-02 / CHK-02B / CHK-04 questionnaire shell driven by [BrainCheckController].
class BrainCheckFlowScreen extends ConsumerStatefulWidget {
  const BrainCheckFlowScreen({super.key});

  @override
  ConsumerState<BrainCheckFlowScreen> createState() =>
      _BrainCheckFlowScreenState();
}

class _BrainCheckFlowScreenState extends ConsumerState<BrainCheckFlowScreen> {
  int? _selected;
  var _submitting = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(brainCheckControllerProvider);
      if (!controller.isHydrated) {
        await controller.hydrate();
      }
      if (!mounted) return;
      _syncSelection(controller);
      setState(() {});
    });
  }

  void _syncSelection(BrainCheckController controller) {
    final q = controller.currentQuestion;
    if (q == null) {
      _selected = null;
      return;
    }
    _selected = controller.progress.answers[q.id]?.value;
  }

  Future<void> _onContinue(BrainCheckController controller) async {
    if (_selected == null || _submitting) return;
    setState(() {
      _submitting = true;
      _localError = null;
    });
    final result = await controller.answerCurrent(_selected);
    if (!mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    setState(() {
      _submitting = false;
      if (!result.isOk) {
        _localError = result.messageForLocale(lang);
      } else {
        _syncSelection(controller);
      }
    });
  }

  Future<void> _onBack(BrainCheckController controller) async {
    await controller.goBack();
    if (!mounted) return;
    setState(() {
      _localError = null;
      _syncSelection(controller);
    });
  }

  Future<void> _onBreakContinue(BrainCheckController controller) async {
    await controller.continueAfterBreak();
    if (!mounted) return;
    setState(() {
      _localError = null;
      _syncSelection(controller);
    });
  }

  Future<void> _onComplete(BrainCheckController controller) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final lang = Localizations.localeOf(context).languageCode;
    final result = await controller.complete(languageCode: lang);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isOk) {
      // CHK-04 → CHK-03 (Build Spec). Temporary complete boundary remains
      // reachable for safe recovery, but the live path builds the Profile.
      context.go(AppRoutes.v2BrainCheckBuilding);
    } else {
      setState(() => _localError = result.messageForLocale(lang));
    }
  }

  void _exitSafe() {
    context.go(AppRoutes.v2Home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.watch(brainCheckControllerProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    if (!controller.isHydrated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Semantics(
            liveRegion: true,
            label: loc.brainCheckLoading,
            child: Text(loc.brainCheckLoading),
          ),
        ),
      );
    }

    final phase = controller.progress.phase;

    // Wrong phase for flow → route safely.
    if (phase == BrainCheckPhase.empty || phase == BrainCheckPhase.intro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.v2BrainCheckEntry);
      });
    }
    if (phase == BrainCheckPhase.resumeGate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.v2BrainCheckEntry);
      });
    }
    if (phase == BrainCheckPhase.completed && controller.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.v2BrainCheckBuilding);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(loc.brainCheckTitle),
        leading: IconButton(
          tooltip: loc.brainCheckExit,
          onPressed: _exitSafe,
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: BrainCheckFlowBody(
          loc: loc,
          languageCode: languageCode,
          controller: controller,
          selected: _selected,
          submitting: _submitting,
          localError: _localError ??
              (controller.lastSaveError != null ? loc.brainCheckSaveError : null),
          onSelect: (v) => setState(() {
            _selected = v;
            _localError = null;
          }),
          onContinue: () => _onContinue(controller),
          onBack: () => _onBack(controller),
          onBreakContinue: () => _onBreakContinue(controller),
          onComplete: () => _onComplete(controller),
        ),
      ),
    );
  }
}

/// Sync-testable questionnaire body.
class BrainCheckFlowBody extends StatelessWidget {
  const BrainCheckFlowBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.controller,
    required this.selected,
    required this.submitting,
    required this.localError,
    required this.onSelect,
    required this.onContinue,
    required this.onBack,
    required this.onBreakContinue,
    required this.onComplete,
  });

  final AppLocalizations loc;
  final String languageCode;
  final BrainCheckController controller;
  final int? selected;
  final bool submitting;
  final String? localError;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onBreakContinue;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final phase = controller.progress.phase;
    if (phase == BrainCheckPhase.sectionBreak) {
      return _BreakView(
        loc: loc,
        languageCode: languageCode,
        controller: controller,
        onContinue: onBreakContinue,
        onBack: onBack,
      );
    }
    if (phase == BrainCheckPhase.completion) {
      return _CompletionView(
        loc: loc,
        submitting: submitting,
        onComplete: onComplete,
        error: localError,
      );
    }
    if (phase != BrainCheckPhase.item) {
      return Center(child: Text(loc.brainCheckLoading));
    }

    final question = controller.currentQuestion;
    if (question == null) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.brainCheckConfigError),
        ),
      );
    }

    return _ItemView(
      loc: loc,
      languageCode: languageCode,
      controller: controller,
      question: question,
      selected: selected,
      submitting: submitting,
      localError: localError,
      onSelect: onSelect,
      onContinue: onContinue,
      onBack: onBack,
    );
  }
}

class _ItemView extends StatelessWidget {
  const _ItemView({
    required this.loc,
    required this.languageCode,
    required this.controller,
    required this.question,
    required this.selected,
    required this.submitting,
    required this.localError,
    required this.onSelect,
    required this.onContinue,
    required this.onBack,
  });

  final AppLocalizations loc;
  final String languageCode;
  final BrainCheckController controller;
  final BrainCheckQuestion question;
  final int? selected;
  final bool submitting;
  final String? localError;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final questions = BrainCheckItemBank.questionsFor(controller.progress.mode);
    final total = questions.length;
    final current = controller.progress.currentQuestionIndex + 1;
    final sections = BrainCheckItemBank.sectionsFor(controller.progress.mode);
    final sectionIndex = controller.progress.currentSectionIndex;
    final section = sections[sectionIndex.clamp(0, sections.length - 1)];
    final canBack = controller.progress.currentQuestionIndex > 0;
    final canContinue = selected != null && !submitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            label: loc.brainCheckQuestionProgress(current, total),
            child: Text(
              loc.brainCheckQuestionProgress(current, total),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.brainCheckSectionProgress(
              sectionIndex + 1,
              sections.length,
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            section.titleForLocale(languageCode),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              question.stemForLocale(languageCode),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 20),
          BrainCheckAnswerControl(
            loc: loc,
            scale: question.scale,
            selected: selected,
            onSelected: onSelect,
          ),
          if (localError != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                localError!,
                style: const TextStyle(color: AppColors.warning),
              ),
            ),
          ],
          if (!canContinue && selected == null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                loc.brainCheckSelectAnswerHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (canBack)
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    tooltip: loc.brainCheckBack,
                    onPressed: submitting ? null : onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      textDirection: Directionality.of(context),
                    ),
                  ),
                )
              else
                const SizedBox(width: 48, height: 48),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: canContinue ? onContinue : null,
                    child: Text(
                      submitting
                          ? loc.brainCheckSaving
                          : loc.brainCheckContinue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.brainCheckAutosaveHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _BreakView extends StatelessWidget {
  const _BreakView({
    required this.loc,
    required this.languageCode,
    required this.controller,
    required this.onContinue,
    required this.onBack,
  });

  final AppLocalizations loc;
  final String languageCode;
  final BrainCheckController controller;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final sections = BrainCheckItemBank.sectionsFor(controller.progress.mode);
    final sectionIndex = controller.progress.currentSectionIndex;
    final section = sections[sectionIndex.clamp(0, sections.length - 1)];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.brainCheckBreakTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.brainCheckBreakBody(section.titleForLocale(languageCode)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onContinue,
              child: Text(loc.brainCheckContinue),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: onBack,
              child: Text(loc.brainCheckBack),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.loc,
    required this.submitting,
    required this.onComplete,
    this.error,
  });

  final AppLocalizations loc;
  final bool submitting;
  final VoidCallback onComplete;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.brainCheckComplete,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.brainCheckCompletionBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            loc.brainCheckIntroNonMedical,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(error!, style: const TextStyle(color: AppColors.warning)),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: submitting ? null : onComplete,
              child: Text(
                submitting ? loc.brainCheckSaving : loc.brainCheckFinish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
