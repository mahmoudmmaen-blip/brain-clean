import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/confirm_dialog.dart';
import '../../../core/theme/app_colors.dart';
import '../application/streak_freeze_provider.dart';

const streakFreezeButtonKey = Key('streak_freeze_button');

/// Focus Journey freeze control — one use per week.
class StreakFreezeButton extends ConsumerWidget {
  const StreakFreezeButton({super.key});

  Future<void> _confirmFreeze(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: loc.focusJourneyFreezeTitle,
      message: loc.streakFreezeConfirm,
      confirmLabel: loc.commonConfirm,
      cancelLabel: loc.commonCancel,
    );
    if (confirmed) {
      ref.read(streakFreezeControllerProvider.notifier).useFreeze();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freeze = ref.watch(streakFreezeControllerProvider);
    final active = freeze.freezesAvailable > 0;
    final color = active ? AppColors.info : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: streakFreezeButtonKey,
        onTap: active ? () => _confirmFreeze(context, ref) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ac_unit, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                '❄️',
                style: TextStyle(color: color, fontSize: 14),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${freeze.freezesAvailable}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
