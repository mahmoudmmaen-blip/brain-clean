import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/app_preferences_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/worry_window_notification_service.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../safa_night_journal_checkin_provider.dart';

class SafaNightJournalCheckinCard extends ConsumerWidget {
  const SafaNightJournalCheckinCard({super.key});

  Future<void> _openTimePicker(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(appPreferencesProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.worryWindowReminderHour,
        minute: prefs.worryWindowReminderMinute,
      ),
    );
    if (picked == null) return;

    await ref.read(appPreferencesProvider.notifier).setWorryWindowReminderTime(
          hour: picked.hour,
          minute: picked.minute,
        );
    await ref.read(worryWindowNotificationServiceProvider).reschedule();
    if (!context.mounted) return;

    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.safaCheckinTimeUpdated)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final showAsync = ref.watch(showSafaNightJournalCheckinProvider);

    return showAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (show) {
        if (!show) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          loc.safaCheckinIcon,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.safaCheckinTitle,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      loc.safaCheckinBody,
                      style: AppDesignConstants.arabicText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                        height: AppDesignConstants.arabicBodyLineHeight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _openTimePicker(context, ref),
                        child: Text(loc.safaCheckinAction),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      await ref
                          .read(appPreferencesProvider.notifier)
                          .dismissSafaCheckinForDays(7);
                      ref.invalidate(showSafaNightJournalCheckinProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
