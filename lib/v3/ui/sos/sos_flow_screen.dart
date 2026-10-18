import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/in_app_review_service.dart';
import '../../application/sos_now_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../content/sos_content.dart';
import '../../data/sos_log.dart';
import '../../data/user_inputs.dart';
import '../../domain/in_app_review_gate.dart';
import '../../domain/sos_helpers.dart';
import '../../domain/sos_night.dart';
import '../../routing/v3_routes.dart';
import '../share/share_card.dart';

class V3SosFlowScreen extends ConsumerStatefulWidget {
  const V3SosFlowScreen({super.key, required this.flowId});

  final String flowId;

  @override
  ConsumerState<V3SosFlowScreen> createState() => _V3SosFlowScreenState();
}

class _V3SosFlowScreenState extends ConsumerState<V3SosFlowScreen>
    with SingleTickerProviderStateMixin {
  int _stepIndex = 0;
  int? _before;
  int? _after;
  int _rateValue = 5;
  bool _finished = false;
  bool _showingOptionalGrounding = false;
  Timer? _autoAdvance;
  late AnimationController _breath;
  final GlobalKey _shareBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _scheduleTextAdvance(int seconds) {
    _autoAdvance?.cancel();
    _autoAdvance = Timer(Duration(seconds: seconds), () {
      if (mounted) _next();
    });
  }

  Future<void> _finish(SosFlow flow) async {
    _autoAdvance?.cancel();
    _breath.stop();
    await ref.read(v3StateRepositoryProvider).appendSosLog(
          SosLog(
            at: DateTime.now(),
            flowId: flow.id,
            before: _before,
            after: _after,
          ),
        );
    ref.invalidate(v3AppStateProvider);
    if (mounted) setState(() => _finished = true);

    // Review only on end screen, never mid-flow.
    final win = InAppReviewGate.isSosWin(before: _before, after: _after);
    if (win) {
      await maybeRequestInAppReview(
        repo: ref.read(v3StateRepositoryProvider),
        review: ref.read(inAppReviewServiceProvider),
        triggerMet: true,
        now: ref.read(sosNowProvider),
      );
      ref.invalidate(v3AppStateProvider);
    }
  }

  void _next({SosFlow? flow}) {
    _autoAdvance?.cancel();
    final f = flow;
    if (f == null) {
      setState(() => _stepIndex++);
      return;
    }
    if (_stepIndex >= f.steps.length - 1) {
      _finish(f);
      return;
    }
    setState(() => _stepIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final contentAsync = ref.watch(v3ContentProvider);
    final stateAsync = ref.watch(v3AppStateProvider);
    final now = ref.watch(sosNowProvider);
    final night = isSosNightWindow(now);
    final bg =
        night ? const Color(0xFF050508) : AppDesignConstants.darkBackground;

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        final flow = bundle.sos.byId(widget.flowId);
        if (flow == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(loc.v3SessionMissingExercise)),
          );
        }
        final inputs = stateAsync.valueOrNull?.userInputs ?? const UserInputs();

        if (_finished) {
          return _EndScreen(
            before: _before,
            after: _after,
            locale: locale,
            night: night,
            shareBoundaryKey: _shareBoundaryKey,
            onBack: () => context.go(V3Routes.today),
            onFocus: () => context.go(V3Routes.toolsFocus),
          );
        }

        if (_showingOptionalGrounding) {
          SosFlowStep? grounding;
          for (final s in flow.steps) {
            if (s.type == 'text') {
              grounding = s;
              break;
            }
          }
          return Scaffold(
            key: Key('v3_sos_runner_${flow.id}'),
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(flow.label.resolve(locale)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                child: Column(
                  key: const Key('v3_sos_step_text'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      grounding?.text?.resolve(locale) ??
                          loc.v3SosBoredGroundingFallback,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.45,
                        color: night
                            ? AppDesignConstants.darkOnSurfaceMuted
                            : null,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _finish(flow),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppDesignConstants.brandGreen,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(loc.v3SosRateContinue),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showingOptionalGrounding = false),
                      child: Text(loc.v3SosBack),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final step = flow.steps[_stepIndex];
        final stepDim = step.dimScreen || night;
        return Scaffold(
          key: Key('v3_sos_runner_${flow.id}'),
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(flow.label.resolve(locale)),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.all(AppDesignConstants.paddingScreen),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildStep(
                          context,
                          flow,
                          step,
                          inputs,
                          locale,
                          loc,
                          bundle.sos,
                          night: night,
                        ),
                      ),
                      if (flow.safety != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            flow.safety!.resolve(locale),
                            key: const Key('v3_sos_safety'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: night
                                  ? const Color(0xFF555555)
                                  : AppDesignConstants.darkOnSurfaceDim,
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (stepDim)
                IgnorePointer(
                  child: Container(
                    key: const Key('v3_sos_dim_overlay'),
                    color: Colors.black.withValues(alpha: night ? 0.35 : 0.55),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context,
    SosFlow flow,
    SosFlowStep step,
    UserInputs inputs,
    String locale,
    AppLocalizations loc,
    SosContent sos, {
    required bool night,
  }) {
    switch (step.type) {
      case 'text':
        final secs = step.seconds ?? 6;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_autoAdvance == null || !_autoAdvance!.isActive) {
            _scheduleTextAdvance(secs);
          }
        });
        return Column(
          key: const Key('v3_sos_step_text'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              step.text?.resolve(locale) ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                height: 1.45,
                color: night ? AppDesignConstants.darkOnSurfaceMuted : null,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _next(flow: flow),
              child: Text(loc.v3SosTapSkip),
            ),
          ],
        );
      case 'rate':
        final isAfter = step.key == 'after';
        if (isAfter) {
          return Column(
            key: Key('v3_sos_step_rate_${step.key ?? 'x'}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                step.text?.resolve(locale) ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, height: 1.4),
              ),
              const SizedBox(height: 24),
              Wrap(
                key: const Key('v3_sos_rate_taps'),
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var n = 1; n <= 10; n++)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FilledButton.tonal(
                        key: Key('v3_sos_rate_tap_$n'),
                        onPressed: () {
                          _after = n;
                          _next(flow: flow);
                        },
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('$n'),
                      ),
                    ),
                ],
              ),
              const Spacer(),
            ],
          );
        }
        return Column(
          key: Key('v3_sos_step_rate_${step.key ?? 'x'}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              step.text?.resolve(locale) ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              '$_rateValue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppDesignConstants.brandGreen,
              ),
            ),
            Slider(
              key: const Key('v3_sos_rate_slider'),
              value: _rateValue.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_rateValue',
              onChanged: (v) => setState(() => _rateValue = v.round()),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                _before = _rateValue;
                _next(flow: flow);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(loc.v3SosRateContinue),
            ),
          ],
        );
      case 'breath':
        return _BreathStep(
          key: const Key('v3_sos_step_breath'),
          step: step,
          locale: locale,
          breath: _breath,
          onDone: () => _next(flow: flow),
        );
      case 'show_why':
        final why = resolveSosWhy(
          inputs: inputs,
          defaultWhy: loc.v3SosDefaultWhy,
        );
        return Column(
          key: const Key('v3_sos_step_why'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              step.text?.resolve(locale) ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppDesignConstants.darkOnSurfaceMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              why,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, height: 1.4),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _next(flow: flow),
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(loc.v3SosRateContinue),
            ),
          ],
        );
      case 'suggest_replacement':
        final duration = step.duration ?? '5';
        final items = resolveSosReplacements(
          sos: sos,
          inputs: inputs,
          duration: duration,
          languageCode: locale,
        );
        final bored = flow.id == 'sos_bored';
        return Column(
          key: const Key('v3_sos_step_replacement'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              step.text?.resolve(locale) ?? '',
              style: const TextStyle(fontSize: 18, height: 1.4),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final item in items)
                    Card(
                      child: ListTile(
                        key: Key('v3_sos_replacement_${item.hashCode}'),
                        title: Text(item),
                        leading: const Icon(Icons.check_circle_outline),
                        onTap: bored
                            ? () => _finish(flow)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            if (bored)
              TextButton(
                key: const Key('v3_sos_bored_optional_grounding'),
                onPressed: () =>
                    setState(() => _showingOptionalGrounding = true),
                child: Text(loc.v3SosOrTryThis),
              )
            else
              FilledButton(
                onPressed: () => _next(flow: flow),
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.v3SosRateContinue),
              ),
          ],
        );
      default:
        return Center(
          child: FilledButton(
            onPressed: () => _next(flow: flow),
            child: Text(loc.v3SosRateContinue),
          ),
        );
    }
  }
}

class _BreathStep extends StatefulWidget {
  const _BreathStep({
    super.key,
    required this.step,
    required this.locale,
    required this.breath,
    required this.onDone,
  });

  final SosFlowStep step;
  final String locale;
  final AnimationController breath;
  final VoidCallback onDone;

  @override
  State<_BreathStep> createState() => _BreathStepState();
}

class _BreathStepState extends State<_BreathStep> {
  Timer? _timer;
  int _remaining = 0;
  bool _started = false;
  String _phase = '';

  @override
  void initState() {
    super.initState();
    _remaining = widget.step.seconds ?? 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    setState(() => _started = true);
    widget.breath.repeat(reverse: true);
    _runPhases();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        widget.breath.stop();
        widget.onDone();
        return;
      }
      setState(() => _remaining--);
    });
  }

  Future<void> _runPhases() async {
    final cycle = widget.step.patternCycle ?? const [4, 0, 6, 0];
    while (mounted && _started && _remaining > 0) {
      if (widget.step.isDoubleSigh) {
        setState(() => _phase = 'in');
        await Future<void>.delayed(const Duration(seconds: 3));
        if (!mounted || !_started) return;
        setState(() => _phase = 'sip');
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!mounted || !_started) return;
        setState(() => _phase = 'out');
        await Future<void>.delayed(const Duration(seconds: 6));
      } else {
        final labels = ['in', 'hold', 'out', 'hold'];
        for (var i = 0; i < cycle.length; i++) {
          final secs = cycle[i];
          if (secs <= 0) continue;
          if (!mounted || !_started) return;
          setState(() => _phase = labels[i % labels.length]);
          await Future<void>.delayed(Duration(seconds: secs));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        const Spacer(),
        AnimatedBuilder(
          animation: widget.breath,
          builder: (context, _) {
            final scale = 0.7 + (widget.breath.value * 0.45);
            return Transform.scale(
              scale: _started ? scale : 1,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppDesignConstants.brandGreen.withValues(alpha: 0.25),
                  border: Border.all(
                    color: AppDesignConstants.brandGreen,
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _phase.isEmpty ? '·' : _phase,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          widget.step.text?.resolve(widget.locale) ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
        const SizedBox(height: 16),
        Text(
          '$_remaining',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (!_started)
          FilledButton(
            onPressed: _start,
            style: FilledButton.styleFrom(
              backgroundColor: AppDesignConstants.brandGreen,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(loc.v3PracticeStart),
          )
        else
          TextButton(
            onPressed: () {
              _timer?.cancel();
              widget.breath.stop();
              widget.onDone();
            },
            child: Text(loc.v3Skip),
          ),
      ],
    );
  }
}

class _EndScreen extends StatelessWidget {
  const _EndScreen({
    required this.before,
    required this.after,
    required this.locale,
    required this.night,
    required this.shareBoundaryKey,
    required this.onBack,
    required this.onFocus,
  });

  final int? before;
  final int? after;
  final String locale;
  final bool night;
  final GlobalKey shareBoundaryKey;
  final VoidCallback onBack;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hasRatings = before != null && after != null;
    final bg =
        night ? const Color(0xFF050508) : AppDesignConstants.darkBackground;
    return Scaffold(
      key: const Key('v3_sos_end'),
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle,
                size: 72,
                color: AppDesignConstants.brandGreen,
              ),
              const SizedBox(height: 16),
              Text(
                loc.v3SosWavePassed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasRatings) ...[
                const SizedBox(height: 16),
                Text(
                  loc.v3SosRatedFromTo(before!, after!),
                  key: const Key('v3_sos_rated_delta'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppDesignConstants.brandGreen,
                  ),
                ),
                // Keep in tree (not Offstage) so RepaintBoundary can rasterize.
                Transform.translate(
                  offset: const Offset(-5000, -5000),
                  child: ShareCard(
                    variant: ShareCardVariant.sosWin(
                      before: before!,
                      after: after!,
                    ),
                    locale: locale,
                    boundaryKey: shareBoundaryKey,
                  ),
                ),
              ],
              const Spacer(),
              if (hasRatings) ...[
                OutlinedButton(
                  key: const Key('v3_sos_share'),
                  onPressed: () => shareShareCardPng(
                    boundaryKey: shareBoundaryKey,
                    shareText: loc.v3SosRatedFromTo(before!, after!),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(loc.v3Share),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: onBack,
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.v3SosBack),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onFocus,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.v3SosStartFocus),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test helper for breath circle scale.
double sosBreathScale(double t) =>
    0.7 + 0.3 * (0.5 + 0.5 * math.sin(t * math.pi));
