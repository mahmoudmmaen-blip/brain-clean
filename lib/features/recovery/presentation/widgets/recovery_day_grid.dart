import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/recovery_day_record.dart';
import '../../domain/recovery_protocol_constants.dart';

/// Tappable 30-cell calendar grid for protocol days.
class RecoveryDayGrid extends StatelessWidget {
  const RecoveryDayGrid({
    super.key,
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
