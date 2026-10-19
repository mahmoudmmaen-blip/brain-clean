import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/usage_providers.dart';
import '../../application/v3_state_providers.dart';
import '../../domain/progress_stats.dart';
import '../../domain/usage_math.dart';
import '../../routing/v3_routes.dart';
import '../share/share_card.dart';

/// Day-30 graduation summary.
class V3GraduationScreen extends ConsumerStatefulWidget {
  const V3GraduationScreen({super.key});

  @override
  ConsumerState<V3GraduationScreen> createState() => _V3GraduationScreenState();
}

class _V3GraduationScreenState extends ConsumerState<V3GraduationScreen> {
  final _shareKey = GlobalKey();

  String _fmtHours(double h) {
    if (h == h.roundToDouble()) return h.toInt().toString();
    return h.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final appAsync = ref.watch(v3AppStateProvider);
    final usageAsync = ref.watch(usageSnapshotProvider);

    return Scaffold(
      key: const Key('v3_graduation'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(loc.v3GraduationTitle),
      ),
      body: appAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (app) {
          final stats = ProgressStats.fromState(
            dayProgress: app.dayProgress,
            clarityResults: app.clarityResults,
            focusLogs: app.focusLogs,
            sosLogs: app.sosLogs,
            now: DateTime.now(),
          );
          final usage = usageAsync.asData?.value;
          final realFromTo = usage != null && usage.hasAccess
              ? UsageMath.firstVsLastWindow(usage.days)
              : null;
          final hoursFrom = realFromTo?.from ?? stats.phoneHoursFirst;
          final hoursTo = realFromTo?.to ?? stats.phoneHoursLatest;
          final letter = app.userInputs.futureLetter?.trim() ?? '';
          final rulesEmpty = app.userInputs.rules.every((r) => r.trim().isEmpty);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                if (stats.hasClarityTrend)
                  Text(
                    loc.v3GraduationClarity(
                      stats.clarityFirst!,
                      stats.clarityLatest!,
                    ),
                    key: const Key('v3_graduation_clarity'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (hoursFrom != null && hoursTo != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    loc.v3GraduationHours(
                      _fmtHours(hoursFrom),
                      _fmtHours(hoursTo),
                    ),
                    key: const Key('v3_graduation_hours'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  loc.v3GraduationDays(stats.daysPracticed),
                  key: const Key('v3_graduation_days'),
                  style: const TextStyle(fontSize: 16),
                ),
                if (letter.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    loc.v3GraduationLetterHeading,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    letter,
                    key: const Key('v3_graduation_letter'),
                    style: const TextStyle(fontSize: 16, height: 1.55),
                  ),
                ],
                const SizedBox(height: 24),
                if (rulesEmpty)
                  OutlinedButton(
                    key: const Key('v3_graduation_write_rules'),
                    onPressed: () => context.push(
                      V3Routes.toolsExercisePath('ex_maintenance_plan'),
                    ),
                    child: Text(loc.v3GraduationWriteRules),
                  ),
                const SizedBox(height: 12),
                Center(
                  child: ShareCard(
                    variant: ShareCardVariant.dayMilestone(
                      days: 30,
                      clarityFrom: stats.clarityFirst,
                      clarityTo: stats.clarityLatest,
                    ),
                    locale: locale,
                    boundaryKey: _shareKey,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('v3_graduation_share'),
                  onPressed: () => shareShareCardPng(boundaryKey: _shareKey),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppDesignConstants.brandGreen,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(loc.v3GraduationShare),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('v3_graduation_whats_next'),
                  onPressed: () => context.go(V3Routes.today),
                  child: Text(loc.v3GraduationWhatsNext),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
