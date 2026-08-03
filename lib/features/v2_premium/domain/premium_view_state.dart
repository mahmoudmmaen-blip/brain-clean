import 'premium_offering.dart';
import 'premium_purchase_phase.dart';

/// Immutable Premium UI / controller snapshot.
class PremiumViewState {
  const PremiumViewState({
    required this.phase,
    this.offerings = const [],
    this.selectedProductId,
    this.isEntitled = false,
    this.messageKey,
    this.source,
    this.busy = false,
  });

  final PremiumPurchasePhase phase;
  final List<PremiumOffering> offerings;
  final String? selectedProductId;
  final bool isEntitled;

  /// Stable key for calm status copy (UI maps to l10n).
  final String? messageKey;
  final String? source;
  final bool busy;

  PremiumOffering? get selectedOffering {
    final id = selectedProductId;
    if (id == null) return null;
    for (final o in offerings) {
      if (o.productId == id) return o;
    }
    return null;
  }

  PremiumViewState copyWith({
    PremiumPurchasePhase? phase,
    List<PremiumOffering>? offerings,
    String? selectedProductId,
    bool? isEntitled,
    String? messageKey,
    String? source,
    bool? busy,
    bool clearMessage = false,
    bool clearSelected = false,
  }) {
    return PremiumViewState(
      phase: phase ?? this.phase,
      offerings: offerings ?? this.offerings,
      selectedProductId:
          clearSelected ? null : (selectedProductId ?? this.selectedProductId),
      isEntitled: isEntitled ?? this.isEntitled,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      source: source ?? this.source,
      busy: busy ?? this.busy,
    );
  }
}
