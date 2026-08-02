/// Item polarity for `brain_check_measurement_v1` (contract §5.2).
enum ItemPolarity { forward, reverse }

/// Authoritative reverse/forward table for Recovery Score V1.
abstract final class ItemPolarityTable {
  static const reverseIds = <String>{
    'full_q3',
    'full_q6',
  };

  static ItemPolarity forQuestionId(String questionId) {
    return reverseIds.contains(questionId)
        ? ItemPolarity.reverse
        : ItemPolarity.forward;
  }
}
