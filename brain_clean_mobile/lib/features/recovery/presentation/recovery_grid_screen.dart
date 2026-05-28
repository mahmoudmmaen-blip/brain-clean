import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../domain/recovery_daily_task.dart';
import '../domain/recovery_day_record.dart';
import '../domain/recovery_protocol_constants.dart';
import '../domain/recovery_protocol_state.dart';
import 'recovery_protocol_controller.dart';
import 'widgets/penalty_box_dialog.dart';
import 'widgets/recovery_day_grid.dart';
import 'widgets/recovery_progress_card.dart';
import 'widgets/recovery_task_tile.dart';

/// 30-day recovery grid with five official daily habits per selected day.
class RecoveryGridScreen extends ConsumerWidget {
  const RecoveryGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final asyncState = ref.watch(recoveryProtocolControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.recoveryGridTitle)),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _RecoveryLoadError(
            message: loc.diagnosticSyncError,
            onRetry: () => ref
                .read(recoveryProtocolControllerProvider.notifier)
                .reloadFromStorage(),
          ),
          data: (state) => _RecoveryGridBody(state: state),
        ),
      ),
    );
  }
}

class _RecoveryLoadError extends StatelessWidget {
  const _RecoveryLoadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.detoxRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryGridBody extends ConsumerWidget {
  const _RecoveryGridBody({required this.state});

  final RecoveryProtocolState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.read(recoveryProtocolControllerProvider.notifier);
    final selected = state.dayRecord(state.selectedDayIndex);
    final showPenaltyPath = controller.selectedDayNeedsPenalty();
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
          RecoveryProgressCard(
            completedDays: state.completedDaysCount,
            totalDays: RecoveryProtocolConstants.dayCount,
            progress: state.progressRatio,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 400 ? 6 : width >= 280 ? 5 : 4;
              return RecoveryDayGrid(
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
            (task) => RecoveryTaskTile(
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
                minimumSize: const Size.fromHeight(
                  AppDesignConstants.minTouchTarget + 4,
                ),
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
    await ref
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
