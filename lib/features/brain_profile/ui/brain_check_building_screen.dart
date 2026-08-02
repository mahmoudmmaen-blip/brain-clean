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
  String? _errorEn;
  String? _errorAr;
  var _building = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _build());
  }

  Future<void> _build() async {
    setState(() {
      _building = true;
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
          _errorEn = 'Complete a Brain Check first.';
          _errorAr = 'أكمل فحص الدماغ أولاً.';
        });
        return;
      }

      final generator = ref.read(brainProfileGeneratorProvider);
      final outcome =
          await generator.generateFrom(result.measurementEvent);

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
        _errorEn = 'Could not build your Brain Profile. Please try again.';
        _errorAr = 'تعذّر بناء ملف الدماغ. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final error = isAr ? (_errorAr ?? _errorEn) : (_errorEn ?? _errorAr);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Semantics(
          liveRegion: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _building
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(value: 0.6),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.brainProfileBuilding,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error ?? loc.brainProfileUnavailable,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _build,
                            child: Text(loc.brainProfileRetry),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: Text(loc.brainProfileGoHome),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
