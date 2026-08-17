/// Exact SAF-01 UI states (Contract §4.4).
enum SafaSessionState {
  idle,
  privacyNotice,
  consentRequired,
  ready,
  sending,
  responseReady,
  localFallback,
  offline,
  timeout,
  serviceUnavailable,
  invalidResponse,
  inputTooLong,
  boundedSessionComplete,
  safetyRedirect,
  userCancelled,
  cleared,
}

extension SafaSessionStateX on SafaSessionState {
  String get wireId => switch (this) {
        SafaSessionState.idle => 'idle',
        SafaSessionState.privacyNotice => 'privacy_notice',
        SafaSessionState.consentRequired => 'consent_required',
        SafaSessionState.ready => 'ready',
        SafaSessionState.sending => 'sending',
        SafaSessionState.responseReady => 'response_ready',
        SafaSessionState.localFallback => 'local_fallback',
        SafaSessionState.offline => 'offline',
        SafaSessionState.timeout => 'timeout',
        SafaSessionState.serviceUnavailable => 'service_unavailable',
        SafaSessionState.invalidResponse => 'invalid_response',
        SafaSessionState.inputTooLong => 'input_too_long',
        SafaSessionState.boundedSessionComplete => 'bounded_session_complete',
        SafaSessionState.safetyRedirect => 'safety_redirect',
        SafaSessionState.userCancelled => 'user_cancelled',
        SafaSessionState.cleared => 'cleared',
      };
}
