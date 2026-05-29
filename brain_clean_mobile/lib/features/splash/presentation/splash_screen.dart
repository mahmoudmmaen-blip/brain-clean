import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bootstrap/app_hydration_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Cold-start gate: hydrates Hive + Riverpod, then home or **live session** resume.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateAndRoute());
  }

  Future<void> _hydrateAndRoute() async {
    var snapshot = const AppHydrationSnapshot(
      hasCommittedSession: false,
      hasDraftProgress: false,
    );
    try {
      snapshot = await ref.read(appHydrationProvider.future);
    } catch (_) {
      // Local Hive remains authoritative; route using defaults below.
    }
    if (!mounted) return;

    // Draft metrics/questionnaire without commit → resume live session flow.
    final resumeLiveSession =
        snapshot.hasDraftProgress && !snapshot.hasCommittedSession;
    context.go(resumeLiveSession ? AppRoutes.diagnostic : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hydration = ref.watch(appHydrationProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 64,
              color: AppTheme.gold,
            ),
            const SizedBox(height: 24),
            Text(
              loc.splashTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            if (hydration.isLoading)
              const CircularProgressIndicator()
            else if (hydration.hasError)
              Text(
                loc.splashHydrationRetry,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
