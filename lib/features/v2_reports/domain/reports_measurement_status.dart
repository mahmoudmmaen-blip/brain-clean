/// Measurement-history status on RPT-01.
enum ReportsMeasurementStatus {
  none,
  baselineOnly,
  comparableAvailable,
  incompatibleOnly,
}

/// Deterministic primary CTA for RPT-01 (contract §4.3).
enum ReportsPrimaryCta {
  openLatestArtifact,
  openMeasurementHistory,
  backToProgress,
  goToToday,
}
