import 'package:flutter/foundation.dart';

/// Internal Edge / model reference — never user-facing recovery IDs.
@immutable
class SafaServiceMetadata {
  const SafaServiceMetadata({
    this.serviceVersionRef = 'safa-chat',
    this.modelHint,
  });

  final String serviceVersionRef;
  final String? modelHint;

  @override
  bool operator ==(Object other) =>
      other is SafaServiceMetadata &&
      other.serviceVersionRef == serviceVersionRef &&
      other.modelHint == modelHint;

  @override
  int get hashCode => Object.hash(serviceVersionRef, modelHint);
}
