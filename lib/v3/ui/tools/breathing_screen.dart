import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';

/// Tools breathing: `double_sigh` (free) or `breath_46` (Pro-gated upstream).
class V3BreathingScreen extends ConsumerStatefulWidget {
  const V3BreathingScreen({super.key, required this.mode});

  final String mode;

  @override
  ConsumerState<V3BreathingScreen> createState() => _V3BreathingScreenState();
}

class _V3BreathingScreenState extends ConsumerState<V3BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breath;
  Timer? _timer;
  int _remaining = 60;
  bool _running = false;
  String _phase = '';

  bool get _isDoubleSigh => widget.mode == 'double_sigh';

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _remaining = _isDoubleSigh ? 45 : 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _breath.repeat(reverse: true);
    _runPhases();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        _breath.stop();
        setState(() {
          _remaining = 0;
          _running = false;
        });
        return;
      }
      setState(() => _remaining--);
    });
  }

  Future<void> _runPhases() async {
    while (mounted && _running && _remaining > 0) {
      if (_isDoubleSigh) {
        setState(() => _phase = 'in');
        await Future<void>.delayed(const Duration(seconds: 3));
        if (!mounted || !_running) return;
        setState(() => _phase = 'sip');
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!mounted || !_running) return;
        setState(() => _phase = 'out');
        await Future<void>.delayed(const Duration(seconds: 6));
      } else {
        setState(() => _phase = 'in');
        await Future<void>.delayed(const Duration(seconds: 4));
        if (!mounted || !_running) return;
        setState(() => _phase = 'out');
        await Future<void>.delayed(const Duration(seconds: 6));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title =
        _isDoubleSigh ? loc.v3ToolsDoubleSigh : loc.v3ToolsBreath46;

    return Scaffold(
      key: Key('v3_breathing_${widget.mode}'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _breath,
                builder: (context, _) {
                  final scale = 0.7 + (_breath.value * 0.45);
                  return Transform.scale(
                    scale: _running ? scale : 1,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppDesignConstants.brandGreen
                            .withValues(alpha: 0.25),
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
              const SizedBox(height: 24),
              Text(
                '$_remaining',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_running)
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
                    _breath.stop();
                    setState(() => _running = false);
                  },
                  child: Text(loc.v3PracticeStop),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
