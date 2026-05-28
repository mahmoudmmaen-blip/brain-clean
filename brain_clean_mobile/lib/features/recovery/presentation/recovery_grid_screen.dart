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

    ref.listen(recoveryProtocolControllerProvider, (previous, next) {
      if (!next.hasValue || !next.hasError) return;
      if (previous?.hasValue == true && previous!.hasError) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.recoveryStorageSaveError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.recoveryGridTitle)),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const _RecoveryLoadingView(),
          error: (error, _) {
            final cached = asyncState.valueOrNull;
            if (cached != null) {
              return Column(
                children: [
                  _RecoveryPersistenceBanner(
                    message: loc.recoveryStorageSaveError,
                    onRetry: () => ref
                        .read(recoveryProtocolControllerProvider.notifier)
                        .reloadFromStorage(),
                  ),
                  Expanded(child: _RecoveryGridBody(state: cached)),
                ],
              );
            }
            return _RecoveryLoadError(
              message: loc.recoveryStorageLoadError,
              onRetry: () => ref
                  .read(recoveryProtocolControllerProvider.notifier)
                  .reloadFromStorage(),
              onReset: () => ref
                  .read(recoveryProtocolControllerProvider.notifier)
                  .resetProtocolStorage(),
              resetLabel: loc.recoveryStorageReset,
            );
          },
          data: (state) => _RecoveryGridBody(state: state),
        ),
      ),
    );
  }
}

class _RecoveryLoadingView extends StatelessWidget {
  const _RecoveryLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.recoveryGridTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryPersistenceBanner extends StatelessWidget {
  const _RecoveryPersistenceBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: theme.colorScheme.onErrorContainer,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  height: 1.35,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.detoxRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryLoadError extends StatelessWidget {
  const _RecoveryLoadError({
    required this.message,
    required this.onRetry,
    required this.onReset,
    required this.resetLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onReset;
  final String resetLabel;

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.arabicBodyStyle,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.detoxRetry),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onReset,
              child: Text(resetLabel),
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
