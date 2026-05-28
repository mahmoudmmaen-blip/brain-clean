import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/recovery_daily_task.dart';
import '../domain/recovery_day_record.dart';
import '../domain/recovery_protocol_constants.dart';
import 'recovery_protocol_controller.dart';
import 'widgets/penalty_box_dialog.dart';

/// 30-day recovery grid with five official daily habits per selected day.
class RecoveryGridScreen extends ConsumerWidget {
  const RecoveryGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(recoveryProtocolDataProvider);
    final controller = ref.read(recoveryProtocolControllerProvider.notifier);
    final selected = state.dayRecord(state.selectedDayIndex);
    final showPenaltyPath = controller.selectedDayNeedsPenalty();
    final theme = Theme.of(context);

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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              _RecoveryProgressCard(
                completedDays: state.completedDaysCount,
                totalDays: RecoveryProtocolConstants.dayCount,
                progress: state.progressRatio,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 400 ? 6 : width >= 280 ? 5 : 4;
                  return _RecoveryDayGrid(
                    columns: columns,
                    selectedDay: state.selectedDayIndex,
                    currentDay: state.currentProtocolDay,
                    days: state.days,
                    onDaySelected: controller.selectDay,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                loc.recoveryDayTasksTitle(state.selectedDayIndex),
                key: const Key('recovery_day_tasks_header'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.recoveryDayTasksProgress(
                  selected.completedCount,
                  RecoveryProtocolConstants.mandatoryTaskCount,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 12),
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
                    title: Text(
                      loc.recoveryDayComplete,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                )
              else if (showPenaltyPath) ...[
                Card(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(loc.recoveryMissedHabitsTitle),
                    subtitle: Text(
                      loc.recoveryMissedHabitsSubtitle,
                      style: TextStyle(color: context.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => _openPenaltyBox(context, ref),
                  icon: const Icon(Icons.gavel_outlined),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  label: Text(loc.recoveryOpenPenaltyBox),
                ),
              ] else if (selected.completedCount == 0)
                Text(
                  loc.recoveryDayEmptyHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSubtle,
                  ),
                ),
              if (state.totalPenaltyCount > 0) ...[
                const SizedBox(height: 16),
                Text(
                  loc.recoveryPenaltyCount(state.totalPenaltyCount),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSubtle,
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
        RecoveryDailyTask.regulatedSleep => loc.recoveryTaskSleepTitle,
        RecoveryDailyTask.antiInflammatoryNutrition =>
          loc.recoveryTaskNutritionTitle,
        RecoveryDailyTask.movementTwentyMinutes => loc.recoveryTaskMovementTitle,
        RecoveryDailyTask.distractionManagement =>
          loc.recoveryTaskDistractionTitle,
        RecoveryDailyTask.mentalSupport => loc.recoveryTaskMentalTitle,
      };

  String _taskSubtitle(AppLocalizations loc, RecoveryDailyTask task) =>
      switch (task) {
        RecoveryDailyTask.regulatedSleep => loc.recoveryTaskSleepSubtitle,
        RecoveryDailyTask.antiInflammatoryNutrition =>
          loc.recoveryTaskNutritionSubtitle,
        RecoveryDailyTask.movementTwentyMinutes =>
          loc.recoveryTaskMovementSubtitle,
        RecoveryDailyTask.distractionManagement =>
          loc.recoveryTaskDistractionSubtitle,
        RecoveryDailyTask.mentalSupport => loc.recoveryTaskMentalSubtitle,
      };

  Future<void> _openPenaltyBox(BuildContext context, WidgetRef ref) async {
    final confirmed = await showPenaltyBoxDialog(context);
    if (!confirmed || !context.mounted) return;
    ref
        .read(recoveryProtocolControllerProvider.notifier)
        .applyPenaltyForSelectedDay();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.recoveryPenaltyApplied),
      ),
    );
  }
}

class _RecoveryProgressCard extends StatelessWidget {
  const _RecoveryProgressCard({
    required this.completedDays,
    required this.totalDays,
    required this.progress,
  });

  final int completedDays;
  final int totalDays;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.recoveryProgressSummary(completedDays, totalDays),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 10,
                backgroundColor: context.surfaceMuted,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryDayGrid extends StatelessWidget {
  const _RecoveryDayGrid({
    required this.columns,
    required this.selectedDay,
    required this.currentDay,
    required this.days,
    required this.onDaySelected,
  });

  final int columns;
  final int selectedDay;
  final int currentDay;
  final Map<int, RecoveryDayRecord> days;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
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
          fill = theme.colorScheme.error.withValues(alpha: 0.22);
        } else if (partial) {
          fill = AppTheme.gold.withValues(alpha: 0.28);
        }

        return Material(
          color: fill ?? theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isToday
                      ? AppTheme.success.withValues(alpha: 0.65)
                      : context.borderMuted,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onDaySelected(day),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: isSelected ? 17 : 15,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                ),
                if (allDone)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.check, size: 12, color: AppTheme.success),
                  ),
              ],
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: context.textMuted),
        ),
        activeColor: AppTheme.success,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
