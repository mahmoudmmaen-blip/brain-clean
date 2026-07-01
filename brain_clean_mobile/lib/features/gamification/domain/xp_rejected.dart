/// Typed rejection from [XpLedgerRepository.append].
enum XpRejectReason {
  duplicateRef,
  clockRollback,
  dailyCapExceeded,
  implausibleAmount,
  invalidAmount,
}

class XpRejected implements Exception {
  const XpRejected(this.reason, [this.detail]);

  final XpRejectReason reason;
  final String? detail;

  @override
  String toString() => 'XpRejected($reason${detail == null ? '' : ': $detail'})';
}
