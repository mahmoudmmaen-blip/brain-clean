/// Local night window for SOS hub prioritization (23:00–05:00).
bool isSosNightWindow(DateTime local) {
  final hour = local.hour;
  return hour >= 23 || hour < 5;
}

/// Reorder SOS flow ids so sleep is first during the night window.
List<T> orderSosFlowsForTime<T>({
  required List<T> flows,
  required String Function(T) idOf,
  required DateTime local,
}) {
  if (!isSosNightWindow(local)) return List<T>.from(flows);
  final sleep = <T>[];
  final rest = <T>[];
  for (final f in flows) {
    if (idOf(f) == 'sos_sleep') {
      sleep.add(f);
    } else {
      rest.add(f);
    }
  }
  return [...sleep, ...rest];
}
