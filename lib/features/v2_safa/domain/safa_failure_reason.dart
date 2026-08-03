/// Typed failures mapped from Edge / network / validation (safe to log).
enum SafaFailureReason {
  none,
  missingConfig,
  notInitialized,
  timeout,
  offline,
  serverError,
  malformedResponse,
  emptyReply,
  invalidResponse,
  inputTooLong,
  emptyInput,
  sessionBoundReached,
  consentRequired,
  network,
  unknown,
}
