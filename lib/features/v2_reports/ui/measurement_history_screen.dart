import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_profile/domain/recovery_score.dart';
import '../application/reports_controller.dart';
import '../data/reports_controller_provider.dart';
import '../domain/measurement_history_engine.dart';
import '../domain/reports_comparison_result.dart';

/// RPT-03 — valid Recovery measurement history (read-only).
class MeasurementHistoryScreen extends ConsumerStatefulWidget {
  const MeasurementHistoryScreen({super.key});

  @override
  ConsumerState<MeasurementHistoryScreen> createState() =>
      _MeasurementHistoryScreenState();
}

class _MeasurementHistoryScreenState
    extends ConsumerState<MeasurementHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsControllerProvider).loadMeasurements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = ref.watch(reportsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(loc.v2ReportsMeasurementHistory),
        ),
        leading: IconButton(
          tooltip: loc.v2ReportsBackOverview,
          onPressed: () => context.go(AppRoutes.v2Reports),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: MeasurementHistoryBody(
          controller: c,
          onBack: () => context.go(AppRoutes.v2Reports),
          onRetry: () => c.loadMeasurements(),
        ),
      ),
    );
  }
}

@visibleForTesting
class MeasurementHistoryBody extends StatelessWidget {
  const MeasurementHistoryBody({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onRetry,
  });

  final ReportsController controller;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final c = controller;
    final lang = Localizations.localeOf(context).languageCode;

    if (c.measurementPhase == MeasurementHistoryPhase.loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Text(loc.v2ReportsLoading),
        ),
      );
    }

    if (c.measurementPhase == MeasurementHistoryPhase.persistenceFailed ||
        c.measurementPhase == MeasurementHistoryPhase.unsupported) {
      return _Message(
        title: c.measurementPhase == MeasurementHistoryPhase.unsupported
            ? loc.v2ReportsUnsupported
            : loc.v2ReportsPersistFailed,
        body: loc.v2ReportsMeasurementErrorBody,
        cta: loc.v2ReportsRetry,
        onCta: onRetry,
      );
    }

    if (c.measurementPhase == MeasurementHistoryPhase.none ||
        c.visibleMeasurements.isEmpty) {
      return _Message(
        title: loc.v2ReportsMeasurementNone,
        body: loc.v2ReportsMeasurementNoneBody,
        cta: loc.v2ReportsBackOverview,
        onCta: onBack,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(loc.v2ReportsSelfReportEstimate),
          const SizedBox(height: 8),
          Text(loc.v2ReportsNoCauseFromHistory),
          const SizedBox(height: 20),
          _ComparisonBlock(comparison: c.comparison),
          const SizedBox(height: 20),
          Text(
            loc.v2ReportsMeasurementListHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final item in c.visibleMeasurements)
            _MeasurementCard(item: item, languageCode: lang),
          if (c.premiumLockedMeasurementCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              loc.v2ReportsPremiumArchiveHint(
                c.premiumLockedMeasurementCount.toString(),
              ),
            ),
          ],
          if (c.showDomainHistory && c.domainHistory.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              loc.v2ReportsDomainHistoryHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final p in c.domainHistory)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  loc.v2ReportsDomainHistoryRow(
                    p.titleForLocale(lang),
                    p.measurementDayKey,
                    p.displayedEstimate?.toString() ?? '—',
                  ),
                ),
              ),
          ] else if (c.visibleMeasurements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              loc.v2ReportsDomainLatestOnly,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final d in c.visibleMeasurements.first.domains)
              Text(
                loc.v2ReportsDomainRow(
                  d.titleForLocale(lang),
                  d.displayedEstimate?.toString() ?? '—',
                ),
              ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onBack,
              child: Text(loc.v2ReportsBackOverview),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonBlock extends StatelessWidget {
  const _ComparisonBlock({required this.comparison});
  final MeasurementComparison comparison;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final text = _comparisonText(loc, comparison);
    return Semantics(
      liveRegion: true,
      label: text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.v2ReportsComparedWithEarlier,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(text),
          if (comparison.tooEarlyToInterpret) ...[
            const SizedBox(height: 6),
            Text(loc.v2ReportsTooEarlyToInterpret),
          ],
          if (comparison.lowConfidence) ...[
            const SizedBox(height: 6),
            Text(loc.v2ReportsLowConfidenceQualifier),
          ],
        ],
      ),
    );
  }

  static String _comparisonText(
    AppLocalizations loc,
    MeasurementComparison c,
  ) {
    switch (c.result) {
      case ReportsComparisonResult.higher:
        return loc.v2ReportsComparisonHigher;
      case ReportsComparisonResult.lower:
        return loc.v2ReportsComparisonLower;
      case ReportsComparisonResult.unchangedWithinRounding:
        return loc.v2ReportsComparisonUnchanged;
      case ReportsComparisonResult.notComparable:
        return loc.v2ReportsComparisonNotComparable;
      case ReportsComparisonResult.insufficientHistory:
        return loc.v2ReportsNotEnoughMeasurements;
    }
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.item,
    required this.languageCode,
  });

  final MeasurementHistoryItem item;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final band = RecoveryScoreBandX.fromWire(item.bandWire);
    final bandLabel =
        languageCode == 'ar' ? band.labelAr : band.labelEn;
    final confidence = _confidence(loc, item.confidenceWire);

    return Semantics(
      container: true,
      label: loc.v2ReportsMeasurementSemantics(
        item.measurementDayKey,
        item.scoreDisplay.toString(),
        confidence,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.v2ReportsMeasuredOn(item.measurementDayKey)),
            Text(loc.v2ReportsScoreValue(item.scoreDisplay.toString())),
            Text(loc.v2ReportsScoreBand(bandLabel)),
            Text(loc.v2ReportsScoreConfidence(confidence)),
          ],
        ),
      ),
    );
  }

  static String _confidence(AppLocalizations loc, String wire) {
    switch (wire) {
      case 'strong':
        return loc.v2ReportsConfidenceStrong;
      case 'moderate':
        return loc.v2ReportsConfidenceModerate;
      case 'provisional':
      default:
        return loc.v2ReportsConfidenceProvisional;
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.body,
    required this.cta,
    required this.onCta,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(title, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(onPressed: onCta, child: Text(cta)),
          ),
        ],
      ),
    );
  }
}
