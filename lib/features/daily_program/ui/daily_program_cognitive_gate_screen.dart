import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../games/color_word_game.dart';
import '../../games/n_back_game.dart';
import '../application/structured_daily_program_provider.dart';
import '../domain/daily_program_activity_kind.dart';

/// Opens Stroop or N-Back, then marks the daily program activity complete.
class DailyProgramCognitiveGateScreen extends ConsumerStatefulWidget {
  const DailyProgramCognitiveGateScreen({
    super.key,
    required this.activityId,
    required this.kind,
    this.day,
  });

  final String activityId;
  final DailyProgramActivityKind kind;
  final DateTime? day;

  @override
  ConsumerState<DailyProgramCognitiveGateScreen> createState() =>
      _DailyProgramCognitiveGateScreenState();
}

class _DailyProgramCognitiveGateScreenState
    extends ConsumerState<DailyProgramCognitiveGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openGame());
  }

  DateTime get _day {
    final raw = widget.day ?? DateTime.now();
    return DateTime(raw.year, raw.month, raw.day);
  }

  Future<void> _openGame() async {
    if (!mounted) return;
    final child = widget.kind == DailyProgramActivityKind.cognitiveNBack
        ? const NBackGameScreen()
        : const ColorWordGameScreen();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => child),
    );
    if (!mounted) return;
    await ref.read(structuredDailyProgramControllerProvider).toggle(
          day: _day,
          activityId: widget.activityId,
          completed: true,
        );
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.v2Home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
