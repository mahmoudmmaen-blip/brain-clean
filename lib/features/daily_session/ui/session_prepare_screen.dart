import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../../recovery_plan/domain/recovery_plan_step.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session_path.dart';

/// SES-01 — prepare / orient before the act.
class SessionPrepareScreen extends ConsumerStatefulWidget {
  const SessionPrepareScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<SessionPrepareScreen> createState() =>
      _SessionPrepareScreenState();
}

class _SessionPrepareScreenState extends ConsumerState<SessionPrepareScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final c = ref.read(dailySessionControllerProvider);
      await c.loadToday();
      await c.ensureSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final c = ref.watch(dailySessionControllerProvider);
    final plan = c.plan;
    final session = c.session;
    final languageCode = isAr ? 'ar' : 'en';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.v2SessionPrepareTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: loc.v2SessionClose,
          onPressed: () => context.go(AppRoutes.v2Today),
        ),
      ),
      body: SafeArea(
        child: session == null || plan == null
            ? Center(child: Text(loc.v2TodayHomeLoading))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        resolveTodayActTitle(plan, languageCode) ??
                            loc.v2TodayPreviewFallbackTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(loc.v2SessionPreparePurpose),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        loc.v2TodayPreviewBecauseHeading,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.dayTemplate.todayPreview.because
                          .forLocale(languageCode),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.recoveryPlanTimeRange(
                        '${plan.dayTemplate.todayPreview.estimatedMinutesMin}',
                        '${plan.dayTemplate.todayPreview.estimatedMinutesMax}',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        loc.v2SessionPathHeading,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<DailySessionPath>(
                      segments: [
                        ButtonSegment(
                          value: DailySessionPath.minimum,
                          label: Text(loc.recoveryPlanMinimumPath),
                        ),
                        ButtonSegment(
                          value: DailySessionPath.standard,
                          label: Text(loc.recoveryPlanStandardPath),
                        ),
                      ],
                      selected: {session.path},
                      onSelectionChanged: (s) {
                        c.selectPath(s.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.v2SessionPathNoShame,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(loc.v2SessionPrepareIncludes),
                    const SizedBox(height: 8),
                    ...session.orderedStepIds.map((id) {
                      RecoveryPlanStep? step;
                      for (final s in plan.steps) {
                        if (s.stepId == id) {
                          step = s;
                          break;
                        }
                      }
                      if (step == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(step.nameForLocale(languageCode)),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      loc.v2SessionA11yHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () async {
                          await c.startAct();
                          if (!context.mounted) return;
                          final id = c.session?.id ?? '';
                          context.go('${AppRoutes.v2SessionAct}?session=$id');
                        },
                        child: Text(loc.v2SessionStartCta),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
