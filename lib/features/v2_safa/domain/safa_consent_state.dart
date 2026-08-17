/// Consent for network-backed Safa (Contract §8).
enum SafaConsentState {
  /// Privacy / AI notice not yet acknowledged this app session.
  noticeRequired,

  /// Notice seen; still needs explicit send consent before first network call.
  consentRequired,

  /// User may send network-backed requests this session.
  granted,

  /// User declined network Safa; local fallback remains available.
  declined,
}
