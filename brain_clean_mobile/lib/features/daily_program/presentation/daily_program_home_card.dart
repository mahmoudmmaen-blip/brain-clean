import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/glass_card.dart';
import '../application/daily_program_provider.dart';

/// Home entry card for the daily hybrid journey.
class DailyProgramHomeCard extends ConsumerWidget {
  const DailyProgramHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(dailyProgramProvider);

    final subtitle = async.when(
      loading: () => loc.dailyProgramHomeStart,
      error: (_, __) => loc.dailyProgramHomeStart,
      data: (state) {
        if (state.isAllDone) return loc.dailyProgramHomeDone;
        if (state.isNotStarted) return loc.dailyProgramHomeStart;
        return loc.dailyProgramHomeInProgress(state.remainingCount);
      },
    );

    return GlassCard(
      child: InkWell(
        onTap: () => context.push(AppRoutes.dailyProgram),
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Text(
              loc.dailyProgramHomeIcon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.dailyProgramHomeTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
