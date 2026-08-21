/// One matrix / pattern-reasoning item with a single correct option index.
class IqQuestion {
  const IqQuestion({
    required this.id,
    required this.stemKey,
    required this.optionKeys,
    required this.correctIndex,
    required this.order,
  });

  final String id;
  final String stemKey;
  final List<String> optionKeys;
  final int correctIndex;
  final int order;
}
