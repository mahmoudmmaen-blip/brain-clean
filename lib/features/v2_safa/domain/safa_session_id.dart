import 'package:flutter/foundation.dart';

/// Opaque ephemeral session id — not recovery data.
@immutable
class SafaSessionId {
  const SafaSessionId(this.value);

  final String value;

  factory SafaSessionId.create([DateTime? now]) {
    final t = (now ?? DateTime.now().toUtc()).microsecondsSinceEpoch;
    return SafaSessionId('safa_$t');
  }

  @override
  bool operator ==(Object other) =>
      other is SafaSessionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
