/// In-memory AI notice acknowledgement for the app process (Contract §8.2).
///
/// Not a blanket license for private history. Sensitive context stays per request.
class SafaConsentStore {
  bool _aiNoticeAcknowledged = false;

  bool get aiNoticeAcknowledged => _aiNoticeAcknowledged;

  void acknowledgeAiNotice() {
    _aiNoticeAcknowledged = true;
  }

  void revokeAiNotice() {
    _aiNoticeAcknowledged = false;
  }
}
