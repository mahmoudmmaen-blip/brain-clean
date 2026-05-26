/// UI copy mirrored from diagnostic widgets until those screens migrate to ARB.
///
/// Widget tests should import these constants instead of inline English literals
/// so a single update tracks screen changes.
abstract final class DiagnosticUiExpectations {
  static const appBarTitle = 'Diagnostic 6-Point Test';
  static const heroLabel = 'BRAIN CLARITY SCORE';
  static const liveSubtitleFragment = 'Live';
  static const breakdownHeader = 'BHI · BC_score breakdown';
  static const committedSubtitlePrefix = 'Committed';
}
