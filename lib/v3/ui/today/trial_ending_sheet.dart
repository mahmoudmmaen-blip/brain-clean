import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/external_link_service.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/trial_status_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../data/v3_app_state.dart';
import '../../domain/trial_status.dart';
import '../onboarding/onboarding_keys.dart';
import '../paywall/paywall_personal_stats.dart';

const _playSubscriptionsUrl =
    'https://play.google.com/store/account/subscriptions';

/// Shows the once-per-trial "trial ends in 2 days" bottom sheet when due.
class TrialEndingHost extends ConsumerStatefulWidget {
  const TrialEndingHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TrialEndingHost> createState() => _TrialEndingHostState();
}

class _TrialEndingHostState extends ConsumerState<TrialEndingHost> {
  bool _presented = false;

  Future<void> _presentIfNeeded(TrialStatus status) async {
    if (_presented || !mounted) return;
    final now = ref.read(trialStatusNowProvider);
    if (!status.shouldShowEndingNotice(now: now)) return;

    // Claim immediately so rebuild / listen races cannot double-present.
    _presented = true;

    V3AppState app = const V3AppState();
    try {
      app = await ref.read(v3AppStateProvider.future);
    } catch (_) {}
    if (!mounted) return;

    final stats = PaywallPersonalStats.fromLocalData(
      dayProgress: app.dayProgress,
      sosLogs: app.sosLogs,
      clarityResults: app.clarityResults,
    );

    final exp = status.expiresAt!;
    await ref.read(v3StateRepositoryProvider).setTrialEndingNoticeKey(
          TrialStatus.expirationKey(exp),
        );

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignConstants.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TrialEndingSheet(
        daysPracticed: stats.completedDays,
        urgesBeaten: stats.urgesBeaten,
        priceString: status.yearlyPriceString ?? '—',
        chargeDate: exp,
      ),
    );
    if (!mounted) return;
    ref.invalidate(trialStatusProvider);
    ref.invalidate(v3AppStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<TrialStatus>>(trialStatusProvider, (prev, next) {
      final status = next.asData?.value;
      if (status == null) return;
      _presentIfNeeded(status);
    });
    return widget.child;
  }
}

class TrialEndingSheet extends StatelessWidget {
  const TrialEndingSheet({
    super.key,
    required this.daysPracticed,
    required this.urgesBeaten,
    required this.priceString,
    required this.chargeDate,
  });

  final int daysPracticed;
  final int urgesBeaten;
  final String priceString;
  final DateTime chargeDate;

  static String formatChargeDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateLabel = formatChargeDate(chargeDate);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          key: V3OnboardingKeys.trialEndingSheet,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.v3TrialEndingTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.v3PaywallChipDays(daysPracticed),
              style: const TextStyle(fontSize: 15),
            ),
            Text(
              loc.v3PaywallChipUrges(urgesBeaten),
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              loc.v3TrialEndingCharge(priceString, dateLabel),
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('v3_trial_ending_continue'),
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(loc.v3TrialEndingContinue),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('v3_trial_ending_manage'),
              onPressed: () async {
                await externalLinkService.openUri(_playSubscriptionsUrl);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(loc.v3TrialEndingManage),
            ),
          ],
        ),
      ),
    );
  }
}
