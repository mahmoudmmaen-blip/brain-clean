import 'package:flutter/foundation.dart';

/// Receives every handled error reported through [logAppError].
typedef AppErrorReporter = void Function(
  String context,
  Object error,
  StackTrace? stackTrace,
);

/// Sink for handled errors — set to forward to a crash reporter.
///
/// Defaults to `null`, which logs to the debug console.
AppErrorReporter? appErrorReporter;

/// Reports an error the app recovered from, so failures are never silent.
///
/// [context] identifies the failing operation, e.g.
/// `'PomodoroController._persistSessionsToday'`.
void logAppError(String context, Object error, [StackTrace? stackTrace]) {
  final reporter = appErrorReporter;
  if (reporter != null) {
    reporter(context, error, stackTrace);
    return;
  }
  debugPrint('$context failed: $error');
  if (stackTrace != null) debugPrint('$stackTrace');
}
