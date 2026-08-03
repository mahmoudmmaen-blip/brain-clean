/// Longitudinal evidence depth for Reports (not Progress / Weekly Review enums).
enum ReportsEvidenceDepth {
  noEvidence,
  earlyEvidence,
  developingEvidence,
  establishedHistory,
}

extension ReportsEvidenceDepthX on ReportsEvidenceDepth {
  String get wireName => switch (this) {
        ReportsEvidenceDepth.noEvidence => 'no_evidence',
        ReportsEvidenceDepth.earlyEvidence => 'early_evidence',
        ReportsEvidenceDepth.developingEvidence => 'developing_evidence',
        ReportsEvidenceDepth.establishedHistory => 'established_history',
      };

  static ReportsEvidenceDepth fromWire(String? raw) {
    switch (raw) {
      case 'established_history':
        return ReportsEvidenceDepth.establishedHistory;
      case 'developing_evidence':
        return ReportsEvidenceDepth.developingEvidence;
      case 'early_evidence':
        return ReportsEvidenceDepth.earlyEvidence;
      case 'no_evidence':
      default:
        return ReportsEvidenceDepth.noEvidence;
    }
  }
}
