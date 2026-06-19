import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import 'seven_day_chart_widget.dart';

const proLockedChartKey = Key('pro_locked_chart');

/// Pro-gated wrapper for the 7-day BCS chart.
class ProGatedSevenDayChart extends ConsumerWidget {
  const ProGatedSevenDayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    if (ref.watch(isProUserProvider)) {
      return const SevenDayChartWidget();
    }

    return GestureDetector(
      key: proLockedChartKey,
      onTap: () => context.push(AppRoutes.proPaywall),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.proGatedChartTitle,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.proGatedChartSubtitle,
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Color(0xFF8B949E)),
          ],
        ),
      ),
    );
  }
}
