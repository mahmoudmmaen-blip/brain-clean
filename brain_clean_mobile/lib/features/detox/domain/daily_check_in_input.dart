/// Partial daily habit metrics accepted by [DetoxProtocolController.processDailyCheckIn].
class DailyCheckInInput {
  const DailyCheckInInput({
    this.boredomBefriended,
    this.delayedGratificationCount,
    this.bodyActivated,
  });

  final bool? boredomBefriended;
  final int? delayedGratificationCount;
  final bool? bodyActivated;
}
