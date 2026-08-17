import 'package:flutter/foundation.dart';

/// One suggested next action label (localized by UI from messageKey or text).
@immutable
class SafaSuggestedAction {
  const SafaSuggestedAction({
    required this.labelKey,
    this.labelOverride,
  });

  /// Localization key resolved by the UI (never Premium upsell).
  final String labelKey;

  /// Optional already-localized short label from Edge (validated length).
  final String? labelOverride;

  @override
  bool operator ==(Object other) =>
      other is SafaSuggestedAction &&
      other.labelKey == labelKey &&
      other.labelOverride == labelOverride;

  @override
  int get hashCode => Object.hash(labelKey, labelOverride);
}
