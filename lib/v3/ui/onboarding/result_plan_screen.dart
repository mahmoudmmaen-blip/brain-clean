import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_onboarding_gate_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../domain/clarity_scoring.dart';
import '../../routing/v3_routes.dart';
import 'onboarding_keys.dart';

class V3ResultPlanScreen extends ConsumerStatefulWidget {
  const V3ResultPlanScreen({super.key});

  @override
  ConsumerState<V3ResultPlanScreen> createState() =>
      _V3ResultPlanScreenState();
}

class _V3ResultPlanScreenState extends ConsumerState<V3ResultPlanScreen> {
  bool _markedOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markOnboardingDone());
  }

  Future<void> _markOnboardingDone() async {
    if (_markedOnboarding) return;
    _markedOnboarding = true;
    final repo = ref.read(v3StateRepositoryProvider);
    final state = await repo.load();
    final profile = state.profile;
    if (profile != null && !profile.onboardingDone) {
      await repo.saveProfile(profile.copyWith(onboardingDone: true));
    }
    ref.read(v3OnboardingGateProvider.notifier).markOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final contentAsync = ref.watch(v3ContentProvider);
    final appStateAsync = ref.watch(v3AppStateProvider);

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (bundle) {
        final clarityResults =
            appStateAsync.valueOrNull?.clarityResults ?? const [];
        final latest = clarityResults.isEmpty ? null : clarityResults.last;
        final score = latest?.score ?? 0;
        final areas = latest?.areas;
        final band = ClarityScoring.bandForScore(bundle.clarityCheck, score);

        return Scaffold(
          backgroundColor: AppDesignConstants.darkBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.v3ClarityScoreLabel,
                    style: const TextStyle(
                      color: AppDesignConstants.darkOnSurfaceMuted,
                    ),
                  ),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppDesignConstants.brandGreen,
                    ),
                  ),
                  Text(
                    band.label.resolve(locale),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppDesignConstants.darkOnSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    band.text.resolve(locale),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: AppDesignConstants.darkOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (areas != null) ...[
                    _AreaBar(
                      label: bundle.clarityCheck.scoring.areas['focus']!
                          .resolve(locale),
                      value: areas.focus,
                    ),
                    _AreaBar(
                      label: bundle.clarityCheck.scoring.areas['control']!
                          .resolve(locale),
                      value: areas.control,
                    ),
                    _AreaBar(
                      label: bundle.clarityCheck.scoring.areas['sleep']!
                          .resolve(locale),
                      value: areas.sleep,
                    ),
                    _AreaBar(
                      label: bundle.clarityCheck.scoring.areas['calm']!
                          .resolve(locale),
                      value: areas.calm,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppDesignConstants.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.v3ResultProgramCard,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (final week in bundle.program.weeks)
                              Expanded(
                                child: Text(
                                  week.title.resolve(locale),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    key: V3OnboardingKeys.resultStartDay1,
                    onPressed: () => context.go(V3Routes.sessionPath(1)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppDesignConstants.brandGreen,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(loc.v3ResultStartDay1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AreaBar extends StatelessWidget {
  const _AreaBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppDesignConstants.darkOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppDesignConstants.darkBorder,
              color: AppDesignConstants.brandGreen,
            ),
          ),
        ],
      ),
    );
  }
}
