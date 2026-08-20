import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../recovery_plan/domain/recovery_plan_step.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session_path.dart';
import '../domain/daily_session_status.dart';

/// SES-02 — guided multi-step practice player.
class SessionActScreen extends ConsumerStatefulWidget {
  const SessionActScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<SessionActScreen> createState() => _SessionActScreenState();
}

class _SessionActScreenState extends ConsumerState<SessionActScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  var _secondsLeft = 0;
  var _timerRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      final c = ref.read(dailySessionControllerProvider);
      await c.loadToday();
      if (c.session?.status == DailySessionStatus.prepared) {
        await c.startAct();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _timer?.cancel();
      _timerRunning = false;
    }
  }

  void _startOptionalTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _secondsLeft = minutes * 60;
      _timerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _secondsLeft = 0;
          _timerRunning = false;
        });
        return;
      }
      setState(() => _secondsLeft -= 1);
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

    if (session != null && session.status == DailySessionStatus.reflecting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('${AppRoutes.v2SessionReflect}?session=${session.id}');
      });
    }

    RecoveryPlanStep? step;
    if (plan != null && session?.currentStep != null) {
      final id = session!.currentStep!.stepId;
      for (final s in plan.steps) {
        if (s.stepId == id) {
          step = s;
          break;
        }
      }
    }

    final progressLabel = session == null
        ? ''
        : loc.v2SessionProgress(
            '${session.currentStepIndex + 1}',
            '${session.steps.length}',
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.v2SessionActTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: loc.v2OnboardingBack,
          onPressed: () => context.go(AppRoutes.v2Today),
        ),
      ),
      body: SafeArea(
        child: (session == null || plan == null || step == null)
            ? Center(child: Text(loc.v2TodayHomeLoading))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      liveRegion: true,
                      label: progressLabel,
                      child: Text(progressLabel),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text(
                        step.nameForLocale(languageCode),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(step.purposeForLocale(languageCode)),
                    const SizedBox(height: 16),
                    Text(
                      session.path == DailySessionPath.minimum
                          ? step.minimumPathForLocale(languageCode)
                          : step.standardPathForLocale(languageCode),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.recoveryPlanTimeRange(
                        '${step.durationMinutesMin}',
                        '${step.durationMinutesMax}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: step.accessibilityAltForLocale(languageCode),
                      child: Text(
                        step.accessibilityAltForLocale(languageCode),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.optional
                          ? loc.v2SessionOptionalLabel
                          : loc.v2SessionRequiredLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_timerRunning || _secondsLeft > 0)
                      Semantics(
                        liveRegion: true,
                        label: loc.v2SessionTimerContext('$_secondsLeft'),
                        child: Text(
                          loc.v2SessionTimerContext('$_secondsLeft'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () =>
                            _startOptionalTimer(step!.durationMinutesMin),
                        child: Text(loc.v2SessionStartTimer),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () async {
                          _timer?.cancel();
                          await c.completeCurrentStep();
                        },
                        child: Text(loc.v2SessionMarkDone),
                      ),
                    ),
                    if (step.optional) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () async {
                            _timer?.cancel();
                            await c.skipCurrentOptionalStep();
                          },
                          child: Text(loc.v2SessionSkipOptional),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: session.currentStepIndex > 0
                            ? () => c.goToPreviousStep()
                            : null,
                        child: Text(loc.v2OnboardingBack),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await c.endActEarly();
                        if (!context.mounted) return;
                        context.go(
                          '${AppRoutes.v2SessionReflect}?session=${session.id}',
                        );
                      },
                      child: Text(loc.v2SessionEndEarly),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
