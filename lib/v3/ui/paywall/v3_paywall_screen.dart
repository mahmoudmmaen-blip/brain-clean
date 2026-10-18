import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/external_link_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../../features/pro/domain/subscription_plan.dart';
import '../../../features/v2_premium/application/premium_controller.dart';
import '../../../features/v2_premium/data/premium_controller_provider.dart';
import '../../../features/v2_premium/domain/premium_offering.dart';
import '../../../features/v2_premium/domain/premium_purchase_phase.dart';
import '../../../features/v2_premium/domain/premium_view_state.dart';
import '../../application/v3_state_providers.dart';
import '../../domain/in_app_review_gate.dart';
import '../../routing/v3_routes.dart';
import 'paywall_personal_stats.dart';
import 'paywall_price_math.dart';

/// Google Play subscriptions center (manage/cancel).
const _playSubscriptionsUrl =
    'https://play.google.com/store/account/subscriptions';

/// V3 paywall — real purchase surface backed by [PremiumController].
class V3PaywallScreen extends ConsumerStatefulWidget {
  const V3PaywallScreen({super.key, this.source});

  final String? source;

  @override
  ConsumerState<V3PaywallScreen> createState() => _V3PaywallScreenState();
}

class _V3PaywallScreenState extends ConsumerState<V3PaywallScreen> {
  late final PremiumController _controller;
  bool _closeVisible = false;
  Timer? _closeTimer;

  bool get _isPersonalSource =>
      widget.source == 'day7' || widget.source == 'locked_day';

  bool get _isDay7 => widget.source == 'day7';

  @override
  void initState() {
    super.initState();
    _controller = ref.read(premiumControllerProvider);
    _controller.addListener(_onChanged);
    Future.microtask(() async {
      await _controller.hydrate(source: widget.source);
      await ref.read(v3StateRepositoryProvider).setLastPaywallShownDate(
            InAppReviewGate.dateKey(DateTime.now()),
          );
    });
    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _closeVisible = true);
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  bool _navigatingAfterPurchase = false;

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    final phase = _controller.state.phase;
    if (!_navigatingAfterPurchase &&
        phase == PremiumPurchasePhase.purchased) {
      _navigatingAfterPurchase = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(V3Routes.today);
      });
    }
  }

  void _close() {
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(V3Routes.today);
  }

  Future<void> _subscribe() async {
    await _controller.purchaseSelected();
  }

  Future<void> _openExternalLink(Future<bool> Function() opener) async {
    final opened = await opener();
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsLinkUnavailable)),
    );
  }

  PaywallPersonalStats? _personalStats() {
    if (!_isPersonalSource) return null;
    final async = ref.watch(v3AppStateProvider);
    final app = async.asData?.value;
    if (app == null) return null;
    return PaywallPersonalStats.fromLocalData(
      dayProgress: app.dayProgress,
      sosLogs: app.sosLogs,
      clarityResults: app.clarityResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final state = _controller.state;
    final isPro = ref.watch(isProUserProvider) || state.isEntitled;
    final phase = state.phase;
    final stats = _personalStats();

    final blocked = phase == PremiumPurchasePhase.failed &&
        state.messageKey == 'blocked_source';
    final offeringsFailed = !isPro &&
        !blocked &&
        (phase == PremiumPurchasePhase.storeUnavailable ||
            phase == PremiumPurchasePhase.noOffering ||
            phase == PremiumPurchasePhase.offlineUnknown ||
            (phase == PremiumPurchasePhase.failed &&
                state.messageKey == 'store_unavailable'));
    final loadingOfferings =
        !isPro && !blocked && !offeringsFailed && phase == PremiumPurchasePhase.loading;

    return Scaffold(
      key: const Key('v3_paywall'),
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _closeVisible
                    ? IconButton(
                        key: const Key('v3_paywall_close'),
                        tooltip: loc.v3PaywallClose,
                        onPressed: _close,
                        icon: Icon(Icons.close, color: colors.textPrimary),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: blocked
                  ? _CenteredMessage(message: loc.v2PremiumUnavailableHere)
                  : isPro
                      ? _SubscribedState(
                          message: _statusMessage(loc, state),
                          onManage: () => _openExternalLink(
                            () => externalLinkService.openUri(
                              _playSubscriptionsUrl,
                            ),
                          ),
                        )
                      : offeringsFailed
                          ? _OfferingsFailedState(
                              message: phase ==
                                      PremiumPurchasePhase.offlineUnknown
                                  ? loc.v2PremiumOfflineUnknown
                                  : loc.v3PaywallPricesFailed,
                              onRetry: () =>
                                  _controller.hydrate(source: widget.source),
                            )
                          : loadingOfferings
                              ? const Center(child: CircularProgressIndicator())
                              : _PaywallBody(
                                  loc: loc,
                                  state: state,
                                  statusMessage: _statusMessage(loc, state),
                                  personal: stats,
                                  showDay7Line: _isDay7,
                                  showPersonalHeader: _isPersonalSource,
                                  onSelect: _controller.selectProduct,
                                  onSubscribe: _subscribe,
                                  onRestore: _controller.restore,
                                  onOpenTerms: () => _openExternalLink(
                                    externalLinkService.openTermsOfUse,
                                  ),
                                  onOpenPrivacy: () => _openExternalLink(
                                    externalLinkService.openPrivacyPolicy,
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calm status copy under the CTA. Cancelled purchases stay silent —
  /// the screen simply returns to idle.
  String? _statusMessage(AppLocalizations loc, PremiumViewState state) {
    switch (state.messageKey) {
      case 'failed':
        return loc.v2PremiumPurchaseFailed;
      case 'pending':
        return loc.v2PremiumPurchasePending;
      case 'restored':
        return loc.v2PremiumRestored;
      case 'nothing_to_restore':
        return loc.v2PremiumNothingToRestore;
      case 'restore_failed':
        return loc.v2PremiumRestoreFailed;
      default:
        return null;
    }
  }
}

class _PaywallBody extends StatelessWidget {
  const _PaywallBody({
    required this.loc,
    required this.state,
    required this.statusMessage,
    required this.personal,
    required this.showDay7Line,
    required this.showPersonalHeader,
    required this.onSelect,
    required this.onSubscribe,
    required this.onRestore,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final AppLocalizations loc;
  final PremiumViewState state;
  final String? statusMessage;
  final PaywallPersonalStats? personal;
  final bool showDay7Line;
  final bool showPersonalHeader;
  final ValueChanged<String> onSelect;
  final VoidCallback onSubscribe;
  final VoidCallback onRestore;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  List<PremiumOffering> get _plans {
    final plans = List<PremiumOffering>.of(state.offerings);
    int rank(SubscriptionPeriod p) => switch (p) {
          SubscriptionPeriod.annual => 0,
          SubscriptionPeriod.monthly => 1,
          SubscriptionPeriod.lifetime => 2,
        };
    plans.sort((a, b) => rank(a.period).compareTo(rank(b.period)));
    return plans;
  }

  PremiumOffering? get _selected {
    final id = state.selectedProductId;
    if (id == null) return null;
    for (final o in _plans) {
      if (o.productId == id) return o;
    }
    return null;
  }

  int? get _savingsPercent {
    double? monthly;
    double? annual;
    for (final o in _plans) {
      final price = PaywallPriceMath.parseStorePrice(o.priceString);
      if (o.period == SubscriptionPeriod.monthly) {
        monthly = price;
      } else if (o.period == SubscriptionPeriod.annual) {
        annual = price;
      }
    }
    if (monthly == null || annual == null) return null;
    return PaywallPriceMath.yearlySavingsPercent(
      monthlyPrice: monthly,
      yearlyPrice: annual,
    );
  }

  String _periodLabel(SubscriptionPeriod period) {
    return switch (period) {
      SubscriptionPeriod.monthly => loc.v3PaywallPlanMonthly,
      SubscriptionPeriod.annual => loc.v3PaywallPlanYearly,
      SubscriptionPeriod.lifetime => loc.v3PaywallPlanLifetime,
    };
  }

  bool get _showTrialCta {
    final selected = _selected;
    if (selected == null) return false;
    return selected.period == SubscriptionPeriod.annual &&
        selected.trialConfirmed &&
        selected.trialDays != null &&
        selected.trialDays! > 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final savings = _savingsPercent;
    final trialCta = _showTrialCta;
    final trialDays = _selected?.trialDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDesignConstants.paddingScreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  showPersonalHeader
                      ? loc.v3PaywallPersonalTitle
                      : loc.v3PaywallTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                if (showPersonalHeader && personal != null) ...[
                  const SizedBox(height: 12),
                  _PersonalChips(stats: personal!, loc: loc),
                ],
                if (showDay7Line) ...[
                  const SizedBox(height: 12),
                  Text(
                    loc.v3PaywallSubDay7,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _Benefit(loc.v3PaywallBenefit1),
                _Benefit(loc.v3PaywallBenefit2),
                _Benefit(loc.v3PaywallBenefit3),
                const SizedBox(height: 12),
                for (final o in _plans)
                  _PlanCard(
                    offering: o,
                    periodLabel: _periodLabel(o.period),
                    selected: o.productId == state.selectedProductId,
                    savingsPercent: o.period == SubscriptionPeriod.annual
                        ? savings
                        : null,
                    approxMonthly: o.period == SubscriptionPeriod.annual
                        ? PaywallPriceMath.monthlyEquivalentAmount(
                            o.priceString,
                          )
                        : null,
                    onTap: () => onSelect(o.productId),
                  ),
                if (statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    statusMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDesignConstants.paddingScreen,
              8,
              AppDesignConstants.paddingScreen,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppDesignConstants.minTouchTarget,
                  child: FilledButton(
                    key: const Key('v3_paywall_subscribe'),
                    onPressed: state.busy || state.selectedProductId == null
                        ? null
                        : onSubscribe,
                    child: state.busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            trialCta
                                ? loc.v3PaywallStartTrialCta(trialDays!)
                                : loc.v3PaywallSubscribeCta,
                          ),
                  ),
                ),
                if (trialCta) ...[
                  const SizedBox(height: 8),
                  Text(
                    loc.v3PaywallTrialDisclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      key: const Key('v3_paywall_restore'),
                      onPressed: state.busy ? null : onRestore,
                      child: Text(loc.v3PaywallRestore),
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                    TextButton(
                      key: const Key('v3_paywall_privacy'),
                      onPressed: onOpenPrivacy,
                      child: Text(loc.settingsPrivacyPolicy),
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                    TextButton(
                      key: const Key('v3_paywall_terms'),
                      onPressed: onOpenTerms,
                      child: Text(loc.v2PremiumTermsLink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalChips extends StatelessWidget {
  const _PersonalChips({required this.stats, required this.loc});

  final PaywallPersonalStats stats;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final chips = <Widget>[];

    // Days chip: always when personal header, even if zero (fallback alone).
    final showOnlyDaysFallback =
        stats.urgesBeaten <= 0 && !stats.hasHours && !stats.hasClarity;
    if (stats.completedDays > 0 || showOnlyDaysFallback) {
      chips.add(
        _chip(context, loc.v3PaywallChipDays(stats.completedDays), 'days'),
      );
    }
    if (stats.urgesBeaten > 0) {
      chips.add(
        _chip(context, loc.v3PaywallChipUrges(stats.urgesBeaten), 'urges'),
      );
    }
    if (stats.hasHours) {
      chips.add(
        _chip(
          context,
          loc.v3PaywallChipHours(
            _formatHours(stats.hoursFrom!),
            _formatHours(stats.hoursTo!),
          ),
          'hours',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
        if (stats.hasClarity) ...[
          const SizedBox(height: 8),
          Text(
            loc.v3PaywallClarityFromTo(stats.clarityFrom!, stats.clarityTo!),
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  String _formatHours(double hours) {
    if (hours == hours.roundToDouble()) return hours.toInt().toString();
    return hours.toStringAsFixed(1);
  }

  Widget _chip(BuildContext context, String label, String id) {
    final colors = AppColors.of(context);
    return Container(
      key: Key('v3_paywall_chip_$id'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryDim,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusPill),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      key: const Key('v3_paywall_benefit'),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(height: 1.35, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _SubscribedState extends StatelessWidget {
  const _SubscribedState({required this.onManage, this.message});

  final VoidCallback onManage;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle, color: AppColors.gold, size: 48),
            const SizedBox(height: 12),
            Text(
              loc.v3PaywallAlreadyPro,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: AppDesignConstants.minTouchTarget,
              child: FilledButton(
                key: const Key('v3_paywall_manage'),
                onPressed: onManage,
                child: Text(loc.v3PaywallManageSubscription),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferingsFailedState extends StatelessWidget {
  const _OfferingsFailedState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: AppDesignConstants.minTouchTarget,
              child: FilledButton(
                key: const Key('v3_paywall_retry'),
                onPressed: onRetry,
                child: Text(loc.v3PaywallTryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.offering,
    required this.periodLabel,
    required this.selected,
    required this.savingsPercent,
    required this.approxMonthly,
    required this.onTap,
  });

  final PremiumOffering offering;
  final String periodLabel;
  final bool selected;
  final int? savingsPercent;
  final String? approxMonthly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final isYearly = offering.period == SubscriptionPeriod.annual;
    final showTrial = offering.trialConfirmed &&
        offering.trialDays != null &&
        offering.trialDays! > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        selected: selected,
        label: offering.semanticsLabel,
        child: InkWell(
          key: Key('v3_paywall_plan_${offering.productId}'),
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusButton),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected && isYearly ? colors.primaryDim : colors.card,
              borderRadius:
                  BorderRadius.circular(AppDesignConstants.radiusButton),
              border: Border.all(
                color: selected ? AppColors.primary : colors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : colors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        periodLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offering.priceString,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      if (approxMonthly != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          loc.v3PaywallApproxMonthly(approxMonthly!),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                      if (showTrial) ...[
                        const SizedBox(height: 4),
                        Text(
                          key: const Key('v3_paywall_trial_badge'),
                          loc.v3PaywallTrialBadge(offering.trialDays!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (savingsPercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(
                        AppDesignConstants.radiusPill,
                      ),
                    ),
                    child: Text(
                      loc.v3PaywallSavePercent(savingsPercent!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.goldText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
