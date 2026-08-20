import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/interactive_diagnostic_controller.dart';
import '../application/interactive_diagnostic_controller_provider.dart';
import '../data/interactive_diagnostic_profile_bridge_provider.dart';
import 'diag_intro_view.dart';
import 'diag_q_view.dart';
import 'diag_result_view.dart';

/// Interactive diagnostic flow: DiagIntro → DiagQ → DiagResult.
class InteractiveDiagnosticFlowScreen extends ConsumerStatefulWidget {
  const InteractiveDiagnosticFlowScreen({super.key});

  @override
  ConsumerState<InteractiveDiagnosticFlowScreen> createState() =>
      _InteractiveDiagnosticFlowScreenState();
}

class _InteractiveDiagnosticFlowScreenState
    extends ConsumerState<InteractiveDiagnosticFlowScreen> {
  var _updatingPlan = false;
  var _planError = false;

  Future<void> _updatePlan(InteractiveDiagnosticController controller) async {
    final result = controller.result;
    if (result == null) return;
    setState(() {
      _updatingPlan = true;
      _planError = false;
    });
    try {
      final bridge = ref.read(interactiveDiagnosticProfileBridgeProvider);
      await bridge.persistAndUpdatePlan(result);
      controller.markPlanUpdated();
    } catch (_) {
      if (mounted) {
        setState(() => _planError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.diagResultPlanError),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.watch(interactiveDiagnosticControllerProvider);

    ref.listen<InteractiveDiagnosticController>(
      interactiveDiagnosticControllerProvider,
      (previous, next) {
        if (next.phase == InteractiveDiagnosticPhase.result &&
            next.result != null &&
            !next.planUpdated &&
            !_updatingPlan) {
          _updatePlan(next);
        }
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: controller.phase == InteractiveDiagnosticPhase.intro
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go(AppRoutes.v2Home),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.goBack,
              ),
        title: Text(loc.diagFlowTitle),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: switch (controller.phase) {
            InteractiveDiagnosticPhase.intro => DiagIntroView(
                key: const ValueKey('diag_intro'),
                onStart: controller.startQuestions,
              ),
            InteractiveDiagnosticPhase.questions => () {
                final question = controller.currentQuestion;
                if (question == null) {
                  return const SizedBox.shrink(
                    key: ValueKey('diag_empty'),
                  );
                }
                return DiagQView(
                  key: ValueKey('diag_q_${controller.questionIndex}'),
                  question: question,
                  questionIndex: controller.questionIndex,
                  selected: controller.selectedAnswer,
                  canAdvance: controller.canAdvance,
                  isLastQuestion: controller.isLastQuestion,
                  onSelect: controller.selectAnswer,
                  onBack: controller.goBack,
                  onContinue: controller.advance,
                );
              }(),
            InteractiveDiagnosticPhase.result => () {
                final result = controller.result;
                if (result == null) {
                  return const SizedBox.shrink(
                    key: ValueKey('diag_result_empty'),
                  );
                }
                return DiagResultView(
                  key: const ValueKey('diag_result'),
                  result: result,
                  planUpdated: controller.planUpdated && !_planError,
                  updatingPlan: _updatingPlan,
                  onContinue: () => context.go(AppRoutes.v2PlanBuilding),
                );
              }(),
          },
        ),
      ),
    );
  }
}
