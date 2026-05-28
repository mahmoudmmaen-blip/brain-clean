import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/recovery_daily_task.dart';
import '../domain/recovery_day_record.dart';
import '../domain/recovery_protocol_constants.dart';
import 'recovery_protocol_controller.dart';
import 'widgets/penalty_box_dialog.dart';

/// 30-day recovery grid with five mandatory daily tasks per selected day.
class RecoveryGridScreen extends ConsumerWidget {
  const RecoveryGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(recoveryProtocolDataProvider);
    final controller = ref.read(recoveryProtocolControllerProvider.notifier);
    final selected = state.dayRecord(state.selectedDayIndex);
    final needsPenalty = controller.selectedDayNeedsPenalty();

    return Scaffold(
      appBar: AppBar(title: Text(loc.recoveryGridTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              loc.recoveryGridSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            const SizedBox(height: 16),
            _RecoveryDayGrid(
              selectedDay: state.selectedDayIndex,
              currentDay: state.currentProtocolDay,
              days: state.days,
              onDaySelected: controller.selectDay,
            ),
            const SizedBox(height: 20),
            Text(
              loc.recoveryDayTasksTitle(state.selectedDayIndex),
              key: const Key('recovery_day_tasks_header'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...RecoveryDailyTask.values.map(
              (task) => _RecoveryTaskCheckbox(
                title: _taskTitle(loc, task),
                subtitle: _taskSubtitle(loc, task),
                value: selected.taskCompleted[task.index],
                onChanged: (v) => controller.toggleTask(task, v),
              ),
            ),
            const SizedBox(height: 12),
            if (selected.allTasksComplete)
              Card(
                color: AppTheme.success.withValues(alpha: 0.12),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: AppTheme.success),
                  title: Text(loc.recoveryDayComplete),
                ),
              )
            else if (needsPenalty) ...[
              Card(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444)),
                  title: Text(loc.recoveryMissedHabitsTitle),
                  subtitle: Text(loc.recoveryMissedHabitsSubtitle),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _openPenaltyBox(context, ref),
                icon: const Icon(Icons.gavel_outlined),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                label: Text(loc.recoveryOpenPenaltyBox),
              ),
            ] else if (selected.completedCount == 0)
              Text(
                loc.recoveryDayEmptyHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
              ),
            if (state.totalPenaltyCount > 0) ...[
              const SizedBox(height: 16),
              Text(
                loc.recoveryPenaltyCount(state.totalPenaltyCount),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  String _taskTitle(AppLocalizations loc, RecoveryDailyTask task) =>
      switch (task) {
        RecoveryDailyTask.boredomSilence => loc.recoveryTaskBoredomTitle,
        RecoveryDailyTask.delayedGratification => loc.recoveryTaskDelayedTitle,
        RecoveryDailyTask.bodyActivation => loc.recoveryTaskBodyTitle,
        RecoveryDailyTask.digitalDiscipline => loc.recoveryTaskDigitalTitle,
        RecoveryDailyTask.deepFocus => loc.recoveryTaskFocusTitle,
      };

  String _taskSubtitle(AppLocalizations loc, RecoveryDailyTask task) =>
      switch (task) {
        RecoveryDailyTask.boredomSilence => loc.recoveryTaskBoredomSubtitle,
        RecoveryDailyTask.delayedGratification =>
          loc.recoveryTaskDelayedSubtitle,
        RecoveryDailyTask.bodyActivation => loc.recoveryTaskBodySubtitle,
        RecoveryDailyTask.digitalDiscipline =>
          loc.recoveryTaskDigitalSubtitle,
        RecoveryDailyTask.deepFocus => loc.recoveryTaskFocusSubtitle,
      };

  Future<void> _openPenaltyBox(BuildContext context, WidgetRef ref) async {
    final confirmed = await showPenaltyBoxDialog(context);
    if (!confirmed || !context.mounted) return;
    ref.read(recoveryProtocolControllerProvider.notifier).applyPenaltyForSelectedDay();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.recoveryPenaltyApplied)),
    );
  }
}

class _RecoveryDayGrid extends StatelessWidget {
  const _RecoveryDayGrid({
    required this.selectedDay,
    required this.currentDay,
    required this.days,
    required this.onDaySelected,
  });

  final int selectedDay;
  final int currentDay;
  final Map<int, RecoveryDayRecord> days;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: RecoveryProtocolConstants.dayCount,
      itemBuilder: (context, index) {
        final day = index + 1;
        final record = days[day];
        final allDone = record != null && record.allTasksComplete;
        final partial = record != null && record.hasMissedHabit;
        final penalized = record?.penaltyApplied ?? false;
        final isSelected = day == selectedDay;
        final isToday = day == currentDay;

        Color? fill;
        if (allDone) {
          fill = AppTheme.success.withValues(alpha: 0.35);
        } else if (penalized) {
          fill = const Color(0xFFEF4444).withValues(alpha: 0.25);
        } else if (partial) {
          fill = AppTheme.gold.withValues(alpha: 0.25);
        }

        return Material(
          color: fill ?? Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                      ? AppTheme.success.withValues(alpha: 0.6)
                      : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onDaySelected(day),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecoveryTaskCheckbox extends StatelessWidget {
  const _RecoveryTaskCheckbox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(title),
        subtitle: Text(subtitle),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
