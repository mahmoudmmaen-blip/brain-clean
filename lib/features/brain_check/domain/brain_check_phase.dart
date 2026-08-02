/// CHK flow surface phases for the Brain Check foundation.
enum BrainCheckPhase {
  /// No draft / empty state → start intro.
  empty,

  /// CHK-01 intro.
  intro,

  /// CHK-02C continue vs start over.
  resumeGate,

  /// CHK-02 item capture.
  item,

  /// CHK-02B micro-break between full-mode sections.
  sectionBreak,

  /// CHK-04 completion beat (before profile build).
  completion,

  /// Answers committed; result available (CHK-03 handoff placeholder).
  completed,
}
