/// Within-user overall score comparison (Reports Contract §12).
enum ReportsComparisonResult {
  higher,
  lower,
  unchangedWithinRounding,
  notComparable,
  insufficientHistory,
}

extension ReportsComparisonResultX on ReportsComparisonResult {
  String get wireName => switch (this) {
        ReportsComparisonResult.higher => 'higher',
        ReportsComparisonResult.lower => 'lower',
        ReportsComparisonResult.unchangedWithinRounding =>
          'unchanged_within_rounding',
        ReportsComparisonResult.notComparable => 'not_comparable',
        ReportsComparisonResult.insufficientHistory => 'insufficient_history',
      };
}
