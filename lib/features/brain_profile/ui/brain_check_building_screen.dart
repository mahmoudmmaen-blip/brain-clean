import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_check/data/brain_check_local_repository_provider.dart';
import '../data/brain_profile_repository_provider.dart';
import '../domain/profile_generation_result.dart';

/// CHK-03 — calm loader while MeasurementEvent → ProfilePack.
class BrainCheckBuildingScreen extends ConsumerStatefulWidget {
  const BrainCheckBuildingScreen({super.key});

  @override
  ConsumerState<BrainCheckBuildingScreen> createState() =>
      _BrainCheckBuildingScreenState();
}

class _BrainCheckBuildingScreenState
    extends ConsumerState<BrainCheckBuildingScreen> {
  var _building = true;
  var _missingEvent = false;
  String? _errorEn;
  String? _errorAr;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _build());
  }

  Future<void> _build() async {
    setState(() {
      _building = true;
      _missingEvent = false;
      _errorEn = null;
      _errorAr = null;
    });

    try {
      final checkRepo = ref.read(brainCheckLocalRepositoryProvider);
      final result = await checkRepo.loadResult();
      if (result == null) {
        if (!mounted) return;
        setState(() {
          _building = false;
          _missingEvent = true;
        });
        return;
      }

      final generator = ref.read(brainProfileGeneratorProvider);
      final outcome = await generator.generateFrom(result.measurementEvent);

      if (!mounted) return;

      if (outcome is ProfileGenerationSuccess) {
        context.go(
          '${AppRoutes.v2BrainProfile}?session=${outcome.profile.source.sessionId}',
        );
        return;
      }
      if (outcome is ProfileGenerationFailure) {
        setState(() {
          _building = false;
          _errorEn = outcome.messageEn;
          _errorAr = outcome.messageAr;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _building = false;
        _errorEn = null;
        _errorAr = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final error = _missingEvent
        ? loc.brainProfileMissingEvent
        : (isAr
            ? (_errorAr ?? _errorEn ?? loc.brainProfileUnavailable)
            : (_errorEn ?? _errorAr ?? loc.brainProfileUnavailable));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BrainCheckBuildingBody(
          loc: loc,
          building: _building,
          error: error,
          missingEvent: _missingEvent,
          reduceMotion: reduceMotion,
          onRetry: _build,
          onGoHome: () => context.go(AppRoutes.home),
          onGoEntry: () => context.go(AppRoutes.v2BrainCheckEntry),
        ),
      ),
    );
  }
}

/// Sync-testable CHK-03 body.
class BrainCheckBuildingBody extends StatelessWidget {
  const BrainCheckBuildingBody({
    super.key,
    required this.loc,
    required this.building,
    required this.error,
    required this.missingEvent,
    required this.reduceMotion,
    required this.onRetry,
    required this.onGoHome,
    required this.onGoEntry,
  });

  final AppLocalizations loc;
  final bool building;
  final String error;
  final bool missingEvent;
  final bool reduceMotion;
  final VoidCallback onRetry;
  final VoidCallback onGoHome;
  final VoidCallback onGoEntry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: building
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        // Determinate calm marker — no fake “brain scan”.
                        value: reduceMotion ? 1.0 : 0.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.brainProfileBuilding,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.brainProfileBuildingHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!missingEvent)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: onRetry,
                          child: Text(loc.brainProfileRetry),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: onGoEntry,
                          child: Text(loc.v2BrainCheckEntryStart),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onGoHome,
                        child: Text(loc.brainProfileGoHome),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
