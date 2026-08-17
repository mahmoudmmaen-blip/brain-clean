import '../domain/premium_eligibility.dart';
import '../domain/premium_offering.dart';
import '../domain/premium_purchase_phase.dart';
import '../domain/premium_store_port.dart';
import '../domain/premium_view_state.dart';

/// V2 Premium controller — navigation/state only; never mutates recovery data.
class PremiumController {
  PremiumController({
    required PremiumStorePort store,
  }) : _store = store;

  final PremiumStorePort _store;

  PremiumViewState _state = const PremiumViewState(
    phase: PremiumPurchasePhase.loading,
  );

  PremiumViewState get state => _state;

  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void _set(PremiumViewState next) {
    _state = next;
    _notify();
  }

  /// Hydrate offerings / entitlement for a contextual source.
  Future<void> hydrate({String? source}) async {
    final allowed = PremiumEligibility.allowsExplicitEntry(source);
    if (!allowed) {
      _set(
        _state.copyWith(
          phase: PremiumPurchasePhase.failed,
          messageKey: 'blocked_source',
          source: source,
          busy: false,
        ),
      );
      return;
    }

    _set(
      _state.copyWith(
        phase: PremiumPurchasePhase.loading,
        source: source,
        busy: true,
        clearMessage: true,
      ),
    );

    final entitled = _store.isEntitled;

    if (!_store.isOnline) {
      if (_store.hasCachedEntitlement || entitled) {
        _set(
          PremiumViewState(
            phase: PremiumPurchasePhase.offlineCachedEntitlement,
            isEntitled: true,
            source: source,
            busy: false,
            messageKey: 'offline_cached',
          ),
        );
      } else {
        _set(
          PremiumViewState(
            phase: PremiumPurchasePhase.offlineUnknown,
            isEntitled: false,
            source: source,
            busy: false,
            messageKey: 'offline_unknown',
          ),
        );
      }
      return;
    }

    if (entitled) {
      _set(
        PremiumViewState(
          phase: PremiumPurchasePhase.alreadyEntitled,
          isEntitled: true,
          source: source,
          busy: false,
          messageKey: 'already_entitled',
        ),
      );
      // Still try to load offerings for manage context (non-fatal).
    }

    try {
      final offerings = await _store.loadOfferings();
      if (entitled) {
        _set(
          PremiumViewState(
            phase: PremiumPurchasePhase.alreadyEntitled,
            offerings: offerings,
            selectedProductId: _defaultSelection(offerings),
            isEntitled: true,
            source: source,
            busy: false,
            messageKey: 'already_entitled',
          ),
        );
        return;
      }
      if (offerings.isEmpty) {
        final unavailable = !_store.isStoreConfigured;
        _set(
          PremiumViewState(
            phase: unavailable
                ? PremiumPurchasePhase.storeUnavailable
                : PremiumPurchasePhase.noOffering,
            offerings: const [],
            isEntitled: false,
            source: source,
            busy: false,
            messageKey:
                unavailable ? 'store_unavailable' : 'no_offering',
          ),
        );
        return;
      }
      _set(
        PremiumViewState(
          phase: PremiumPurchasePhase.offeringReady,
          offerings: offerings,
          selectedProductId: _defaultSelection(offerings),
          isEntitled: false,
          source: source,
          busy: false,
        ),
      );
    } catch (_) {
      _set(
        PremiumViewState(
          phase: PremiumPurchasePhase.storeUnavailable,
          isEntitled: entitled,
          source: source,
          busy: false,
          messageKey: 'store_unavailable',
        ),
      );
    }
  }

  void selectProduct(String productId) {
    if (_state.busy || _state.isEntitled) return;
    _set(_state.copyWith(selectedProductId: productId));
  }

  Future<void> purchaseSelected() async {
    final id = _state.selectedProductId;
    if (id == null || _state.busy) return;
    if (_state.isEntitled) {
      _set(
        _state.copyWith(
          phase: PremiumPurchasePhase.alreadyEntitled,
          messageKey: 'already_entitled',
        ),
      );
      return;
    }
    if (!_store.isOnline) {
      _set(
        _state.copyWith(
          phase: PremiumPurchasePhase.offlineUnknown,
          messageKey: 'offline_unknown',
        ),
      );
      return;
    }

    _set(
      _state.copyWith(
        phase: PremiumPurchasePhase.purchasing,
        busy: true,
        messageKey: 'purchasing',
      ),
    );

    final outcome = await _store.purchase(id);
    switch (outcome) {
      case PremiumPurchaseOutcome.success:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.purchased,
            isEntitled: true,
            busy: false,
            messageKey: 'purchased',
          ),
        );
      case PremiumPurchaseOutcome.alreadyEntitled:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.alreadyEntitled,
            isEntitled: true,
            busy: false,
            messageKey: 'already_entitled',
          ),
        );
      case PremiumPurchaseOutcome.cancelled:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.cancelled,
            busy: false,
            messageKey: 'cancelled',
          ),
        );
      case PremiumPurchaseOutcome.failed:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.failed,
            busy: false,
            messageKey: 'failed',
          ),
        );
      case PremiumPurchaseOutcome.pending:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.pending,
            busy: false,
            messageKey: 'pending',
          ),
        );
    }
  }

  Future<void> restore() async {
    if (_state.busy && _state.phase == PremiumPurchasePhase.restoring) {
      return;
    }
    _set(
      _state.copyWith(
        phase: PremiumPurchasePhase.restoring,
        busy: true,
        messageKey: 'restoring',
      ),
    );

    final outcome = await _store.restore();
    switch (outcome) {
      case PremiumRestoreOutcome.restored:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.restored,
            isEntitled: true,
            busy: false,
            messageKey: 'restored',
          ),
        );
      case PremiumRestoreOutcome.nothingToRestore:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.nothingToRestore,
            isEntitled: _store.isEntitled,
            busy: false,
            messageKey: 'nothing_to_restore',
          ),
        );
      case PremiumRestoreOutcome.failed:
        _set(
          _state.copyWith(
            phase: PremiumPurchasePhase.failed,
            busy: false,
            messageKey: 'restore_failed',
          ),
        );
    }
  }

  String? _defaultSelection(List<PremiumOffering> offerings) {
    if (offerings.isEmpty) return null;
    for (final o in offerings) {
      if (o.period.name == 'annual') return o.productId;
    }
    return offerings.first.productId;
  }
}
