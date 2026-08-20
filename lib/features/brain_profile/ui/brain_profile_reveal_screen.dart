import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../v2_onboarding/data/v2_onboarding_repository_provider.dart';
import '../data/brain_profile_repository_provider.dart';
import '../domain/brain_profile_domain_result.dart';
import '../domain/measurement_confidence.dart';
import '../domain/profile_domain_catalog.dart';
import '../domain/profile_pack.dart';
import '../domain/recovery_score.dart';
import 'brain_profile_domain_detail_body.dart';

/// PRF-01 / ONB-07 — calm Brain Profile reveal.
class BrainProfileRevealScreen extends ConsumerStatefulWidget {
  const BrainProfileRevealScreen({
    super.key,
    this.sessionId,
  });

  final String? sessionId;

  @override
  ConsumerState<BrainProfileRevealScreen> createState() =>
      _BrainProfileRevealScreenState();
}

class _BrainProfileRevealScreenState
    extends ConsumerState<BrainProfileRevealScreen> {
  ProfilePack? _pack;
  var _loading = true;
  var _missing = false;
  var _historical = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _missing = false;
    });
    try {
      final repo = ref.read(brainProfileRepositoryProvider);
      ProfilePack? pack;
      var historical = false;
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        pack = await repo.findBySourceSessionId(widget.sessionId!);
        final latest = await repo.latest();
        historical = pack != null && latest != null && pack.id != latest.id;
      } else {
        pack = await repo.latest();
      }
      if (!mounted) return;
      setState(() {
        _pack = pack;
        _missing = pack == null;
        _historical = historical;
        _loading = false;
      });
      if (pack != null) {
        await _recordOnboardingMilestone(pack.source.sessionId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pack = null;
        _missing = true;
        _loading = false;
      });
    }
  }

  Future<void> _recordOnboardingMilestone(String sessionId) async {
    try {
      final controller = ref.read(v2OnboardingControllerProvider);
      if (!controller.isHydrated) {
        await controller.hydrate();
      }
      await controller.markProfileRevealed(sessionId: sessionId);
    } catch (_) {
      // Profile reveal must not fail if onboarding box is unavailable.
    }
  }

  Future<void> _openDomain(String domainId) async {
    final domain = ProfileDomainCatalog.byId(domainId);
    final pack = _pack;
    if (domain == null || pack == null || !mounted) return;
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    BrainProfileDomainResult? result;
    for (final d in pack.domains) {
      if (d.domainId == domainId) {
        result = d;
        break;
      }
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: BrainProfileDomainDetailBody(
            loc: loc,
            languageCode: isAr ? 'ar' : 'en',
            domain: domain,
            result: result,
            pack: pack,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        );
      },
    );
  }

  void _continueToPlan() {
    final pack = _pack;
    if (pack == null || !pack.hasValidRecoveryScore) return;
    context.go(AppRoutes.v2PlanBuilding);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.brainProfileTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: BrainProfileRevealBody(
          loc: loc,
          languageCode: isAr ? 'ar' : 'en',
          loading: _loading,
          missing: _missing,
          historical: _historical,
          pack: _pack,
          onDomainTap: _openDomain,
          onGoHome: () => context.go(AppRoutes.v2Home),
          onContinue: _continueToPlan,
        ),
      ),
    );
  }
}

/// Sync-testable PRF-01 body (loading / empty / ready).
class BrainProfileRevealBody extends StatelessWidget {
  const BrainProfileRevealBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.missing,
    required this.historical,
    required this.pack,
    required this.onDomainTap,
    required this.onGoHome,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final bool missing;
  final bool historical;
  final ProfilePack? pack;
  final Future<void> Function(String domainId) onDomainTap;
  final VoidCallback onGoHome;
  final VoidCallback onContinue;

  String _confidenceLabel(MeasurementConfidence c) {
    return switch (c) {
      MeasurementConfidence.provisional =>
        loc.brainProfileConfidenceProvisional,
      MeasurementConfidence.moderate => loc.brainProfileConfidenceModerate,
      // Contract §10.4: Strong (ARB key retained for compatibility).
      MeasurementConfidence.strong => loc.brainProfileConfidenceSolid,
    };
  }

  String _bandLabel(RecoveryScoreBand band) {
    return languageCode == 'ar' ? band.labelAr : band.labelEn;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Semantics(
        liveRegion: true,
        label: loc.brainProfileLoading,
        child: const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(value: 0.6),
          ),
        ),
      );
    }
    if (missing || pack == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                loc.brainProfileMissing,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(loc.brainProfileEmptyHint, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onGoHome,
                child: Text(loc.brainProfileGoHome),
              ),
            ),
          ],
        ),
      );
    }

    final explanation = pack!.explanation;
    final confidenceLabel = _confidenceLabel(pack!.confidence);
    final score = pack!.recoveryScore;
    final canContinue = score.isValid;
    final scoreSemantics = score.isValid
        ? loc.brainProfileScoreSemantics('${score.value}')
        : score.isUnavailable
            ? loc.brainProfileScoreUnavailableSemantics
            : loc.brainProfileScorePendingSemantics;
    final scoreLabel = score.isValid
        ? '${score.value}'
        : score.isUnavailable
            ? loc.brainProfileScoreUnavailableLabel
            : loc.brainProfileScorePendingLabel;
    final bandText = score.isValid ? _bandLabel(score.band) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (historical) ...[
            Text(
              loc.brainProfileHistoricalBadge,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
          ],
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileOrientation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation.whatItIs(languageCode)),
          const SizedBox(height: 8),
          Text(explanation.whatItIsNot(languageCode)),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileScoreHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: scoreSemantics,
            child: Text(
              scoreLabel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (bandText != null) ...[
            const SizedBox(height: 8),
            Semantics(
              label: '${loc.brainProfileBandHeading}: $bandText',
              child: Text(
                bandText,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 4),
            Text(loc.brainProfileBandMeaning),
          ],
          const SizedBox(height: 8),
          Text(
            score.isUnavailable
                ? loc.brainProfileScoreUnavailableBody
                : explanation.scorePending(languageCode),
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileConfidenceHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '${loc.brainProfileConfidenceHeading}: $confidenceLabel. '
                '${explanation.confidence(languageCode)}',
            child: Text(confidenceLabel),
          ),
          const SizedBox(height: 8),
          Text(explanation.confidence(languageCode)),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileMeansHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(loc.brainProfileMeansBody),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileDoesNotMeanHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation.whatItIsNot(languageCode)),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileDomainsHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation.strongerAreas(languageCode)),
          const SizedBox(height: 8),
          Text(explanation.supportAreas(languageCode)),
          const SizedBox(height: 12),
          ...pack!.domains.map((d) {
            final meanLabel = d.displayScore == null && d.normalizedMean == null
                ? loc.brainProfileDomainNoData
                : loc.brainProfileDomainMean(
                    '${d.displayScore ?? (d.normalizedMean! + 0.5).floor()}',
                  );
            final tag = pack!.strongerDomainIds.contains(d.domainId)
                ? loc.brainProfileDomainStrongerLabel
                : pack!.supportDomainIds.contains(d.domainId)
                    ? loc.brainProfileDomainSupportLabel
                    : null;
            return Semantics(
              button: true,
              label:
                  '${d.titleForLocale(languageCode)}. $meanLabel${tag == null ? '' : '. $tag'}',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 12,
                title: Text(d.titleForLocale(languageCode)),
                subtitle: Text(
                  tag == null ? meanLabel : '$meanLabel · $tag',
                ),
                onTap: () => onDomainTap(d.domainId),
              ),
            );
          }),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              loc.brainProfileExplainHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation.whyMayChange(languageCode)),
          const SizedBox(height: 8),
          Text(explanation.retake(languageCode)),
          const SizedBox(height: 32),
          if (!canContinue) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                loc.brainProfileContinueUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canContinue ? onContinue : null,
              child: Text(loc.brainProfileContinue),
            ),
          ),
        ],
      ),
    );
  }
}
