import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/async_state_views.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../shared/widgets/glass_card.dart';
import 'anxiety_latest_result_provider.dart';
import 'anxiety_localization.dart';
import 'widgets/anxiety_score_ring.dart';

/// Results screen for the chronic anxiety assessment.
class AnxietyResultScreen extends ConsumerWidget {
  const AnxietyResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final latestAsync = ref.watch(anxietyLatestResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.anxietyResultTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: latestAsync.when(
        loading: () => AsyncStateViews.loading(context),
        error: (_, __) => Center(
          child: Text(
            loc.anxietyLoadError,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        data: (result) {
          if (result == null) {
            return Center(
              child: Text(
                loc.anxietyNoResultYet,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          final levelLabel = anxietyLevelLabelFor(loc, result.level);
          final interpretation =
              anxietyInterpretationFor(loc, result.level);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              Center(
                child: AnxietyScoreRing(scorePercent: result.score),
              ),
              const SizedBox(height: 20),
              Text(
                levelLabel,
                textAlign: TextAlign.center,
                style: AppDesignConstants.arabicText(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Text(
                  interpretation,
                  textAlign: TextAlign.center,
                  style: AppDesignConstants.arabicText(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    height: AppDesignConstants.arabicBodyLineHeight,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.go(AppRoutes.safa),
                child: Text(loc.anxietyStartProgramCta),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.push(AppRoutes.anxietyDiagnostic),
                child: Text(loc.anxietyRetakeTest),
              ),
            ],
          );
        },
      ),
    );
  }
}
