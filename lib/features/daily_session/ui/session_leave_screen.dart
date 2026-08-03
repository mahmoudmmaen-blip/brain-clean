import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session_path.dart';

/// SES-04 — calm leave / close.
class SessionLeaveScreen extends ConsumerWidget {
  const SessionLeaveScreen({
    super.key,
    this.sessionId,
    this.done = true,
  });

  final String? sessionId;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(dailySessionControllerProvider).session;
    final pathLabel = session?.path == DailySessionPath.minimum
        ? loc.recoveryPlanMinimumPath
        : loc.recoveryPlanStandardPath;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  done
                      ? loc.v2SessionLeaveSuccess
                      : loc.v2SessionLeavePartial,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.v2SessionLeavePath(pathLabel),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.v2SessionLeaveBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.v2SessionLeaveNext,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.v2Today),
                  child: Text(loc.v2SessionLeaveCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
