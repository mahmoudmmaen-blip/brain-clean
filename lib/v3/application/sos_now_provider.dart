import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable clock for SOS night-window ordering (tests override).
final sosNowProvider = Provider<DateTime>((ref) => DateTime.now());
