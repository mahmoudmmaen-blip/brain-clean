import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/premium_purchase_phase.dart';
import '../domain/premium_view_state.dart';

/// Maps phase/message keys to calm localized copy.
String premiumStatusMessage(AppLocalizations loc, PremiumViewState state) {
  switch (state.messageKey) {
    case 'purchasing':
      return loc.v2PremiumPurchaseInProgress;
    case 'purchased':
      return loc.v2PremiumPurchaseCompleted;
    case 'cancelled':
      return loc.v2PremiumPurchaseCancelled;
    case 'failed':
      return loc.v2PremiumPurchaseFailed;
    case 'pending':
      return loc.v2PremiumPurchasePending;
    case 'no_offering':
      return loc.v2PremiumNoPlansAvailable;
    case 'store_unavailable':
      return loc.v2PremiumStoreUnavailable;
    case 'restored':
      return loc.v2PremiumRestored;
    case 'nothing_to_restore':
      return loc.v2PremiumNothingToRestore;
    case 'restore_failed':
      return loc.v2PremiumRestoreFailed;
    case 'already_entitled':
      return loc.v2PremiumAlreadyActive;
    case 'offline_cached':
      return loc.v2PremiumOfflineCached;
    case 'offline_unknown':
      return loc.v2PremiumOfflineUnknown;
    case 'restoring':
      return loc.v2PremiumRestoring;
    case 'blocked_source':
      return loc.v2PremiumUnavailableHere;
    case 'expired':
      return loc.v2PremiumSubscriptionExpired;
    default:
      break;
  }
  return switch (state.phase) {
    PremiumPurchasePhase.loading => loc.v2PremiumLoading,
    PremiumPurchasePhase.offeringReady => loc.v2PremiumOrientation,
    PremiumPurchasePhase.noOffering => loc.v2PremiumNoPlansAvailable,
    PremiumPurchasePhase.storeUnavailable => loc.v2PremiumStoreUnavailable,
    PremiumPurchasePhase.alreadyEntitled => loc.v2PremiumAlreadyActive,
    PremiumPurchasePhase.purchased => loc.v2PremiumPurchaseCompleted,
    PremiumPurchasePhase.restored => loc.v2PremiumRestored,
    PremiumPurchasePhase.nothingToRestore => loc.v2PremiumNothingToRestore,
    PremiumPurchasePhase.cancelled => loc.v2PremiumPurchaseCancelled,
    PremiumPurchasePhase.failed => loc.v2PremiumPurchaseFailed,
    PremiumPurchasePhase.pending => loc.v2PremiumPurchasePending,
    PremiumPurchasePhase.purchasing => loc.v2PremiumPurchaseInProgress,
    PremiumPurchasePhase.restoring => loc.v2PremiumRestoring,
    PremiumPurchasePhase.offlineCachedEntitlement => loc.v2PremiumOfflineCached,
    PremiumPurchasePhase.offlineUnknown => loc.v2PremiumOfflineUnknown,
  };
}

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.statusAnnouncement,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final String? statusAnnouncement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(title),
        ),
        leading: onClose == null
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (statusAnnouncement != null)
              ExcludeSemantics(
                child: SizedBox(
                  height: 0,
                  child: Semantics(
                    liveRegion: true,
                    label: statusAnnouncement,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class PremiumPrimaryButton extends StatelessWidget {
  const PremiumPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class PremiumSecondaryButton extends StatelessWidget {
  const PremiumSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
