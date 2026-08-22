import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../application/structured_daily_program_provider.dart';

/// Evening written review — saves then marks the daily program item complete.
class EveningReviewScreen extends ConsumerStatefulWidget {
  const EveningReviewScreen({
    super.key,
    required this.activityId,
    this.day,
  });

  final String activityId;
  final DateTime? day;

  @override
  ConsumerState<EveningReviewScreen> createState() =>
      _EveningReviewScreenState();
}

class _EveningReviewScreenState extends ConsumerState<EveningReviewScreen> {
  final _controller = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime get _day {
    final raw = widget.day ?? DateTime.now();
    return DateTime(raw.year, raw.month, raw.day);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final palette = AppColors.of(context);
    final canSave = _controller.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.dailyProgramEveningReviewTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.v2Home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.dailyProgramEveningReviewPrompt,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  key: const Key('evening_review_input'),
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: loc.dailyProgramEveningReviewHint,
                    filled: true,
                    fillColor: palette.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: AppDesignConstants.minTouchTarget,
                child: FilledButton(
                  key: const Key('evening_review_save'),
                  onPressed: canSave ? _save : null,
                  style: V2ShellVisual.primaryFilled(),
                  child: Text(loc.dailyProgramEveningReviewSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
