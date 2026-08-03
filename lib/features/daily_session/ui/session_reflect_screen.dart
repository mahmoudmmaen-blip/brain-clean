import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session_reflection.dart';

/// SES-03 — structured reflection (chips only; no free text).
class SessionReflectScreen extends ConsumerStatefulWidget {
  const SessionReflectScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<SessionReflectScreen> createState() =>
      _SessionReflectScreenState();
}

class _SessionReflectScreenState extends ConsumerState<SessionReflectScreen> {
  String? _manageable;
  String? _helped;
  String? _obstacle;
  var _saving = false;

  Future<void> _save({required bool skipChips}) async {
    setState(() => _saving = true);
    final c = ref.read(dailySessionControllerProvider);
    final reflection = DailySessionReflection(
      promptId: DailySessionReflection.promptIdV1,
      manageableChip: skipChips ? null : _manageable,
      helpedPauseChip: skipChips ? null : _helped,
      obstacleChip: skipChips ? null : _obstacle,
      skippedChips: skipChips,
    );
    final leaveAnyway = !(c.session?.allRequiredComplete ?? false);
    final mark = await c.completeWithReflection(
      reflection: reflection,
      leaveAnyway: leaveAnyway,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (mark == null) return;
    context.go(
      '${AppRoutes.v2SessionLeave}?session=${mark.dailySessionId}'
      '&done=${mark.fullCompletion ? 1 : 0}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.v2SessionReflectTitle),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  loc.v2SessionReflectPrompt,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Text(loc.v2SessionReflectManageable),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(loc.v2SessionChipEasy, 'manageable', _manageable, (v) {
                    setState(() => _manageable = v);
                  }),
                  _chip(loc.v2SessionChipOk, 'ok', _manageable, (v) {
                    setState(() => _manageable = v);
                  }),
                  _chip(loc.v2SessionChipHard, 'hard', _manageable, (v) {
                    setState(() => _manageable = v);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Text(loc.v2SessionReflectHelped),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(loc.v2SessionChipYes, 'yes', _helped, (v) {
                    setState(() => _helped = v);
                  }),
                  _chip(loc.v2SessionChipSomewhat, 'somewhat', _helped, (v) {
                    setState(() => _helped = v);
                  }),
                  _chip(loc.v2SessionChipNotYet, 'not_yet', _helped, (v) {
                    setState(() => _helped = v);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Text(loc.v2SessionReflectObstacle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(loc.v2SessionChipNone, 'none', _obstacle, (v) {
                    setState(() => _obstacle = v);
                  }),
                  _chip(loc.v2SessionChipDistraction, 'distraction', _obstacle,
                      (v) {
                    setState(() => _obstacle = v);
                  }),
                  _chip(loc.v2SessionChipLowEnergy, 'low_energy', _obstacle,
                      (v) {
                    setState(() => _obstacle = v);
                  }),
                  _chip(loc.v2SessionChipTime, 'time', _obstacle, (v) {
                    setState(() => _obstacle = v);
                  }),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : () => _save(skipChips: false),
                  child: Text(
                    _saving ? loc.v2SessionSaving : loc.v2SessionReflectSave,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _saving ? null : () => _save(skipChips: true),
                  child: Text(loc.v2SessionReflectSkipChips),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    String value,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = selected == value;
    return SizedBox(
      height: 48,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelect(value),
      ),
    );
  }
}
