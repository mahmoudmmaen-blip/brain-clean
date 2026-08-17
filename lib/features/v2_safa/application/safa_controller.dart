import '../data/safa_consent_store.dart';
import '../data/safa_edge_adapter.dart';
import '../domain/safa_consent_state.dart';
import '../domain/safa_context_category.dart';
import '../domain/safa_eligibility.dart';
import '../domain/safa_failure_reason.dart';
import '../domain/safa_local_fallback.dart';
import '../domain/safa_request.dart';
import '../domain/safa_request_mapper.dart';
import '../domain/safa_session.dart';
import '../domain/safa_session_id.dart';
import '../domain/safa_session_limit.dart';
import '../domain/safa_session_origin.dart';
import '../domain/safa_session_state.dart';

/// V2 Safa controller — navigates / advises only; never mutates recovery data.
class SafaController {
  SafaController({
    required SafaEdgeAdapter edge,
    required SafaConsentStore consentStore,
    DateTime Function()? clock,
  })  : _edge = edge,
        _consentStore = consentStore,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final SafaEdgeAdapter _edge;
  final SafaConsentStore _consentStore;
  final DateTime Function() _clock;

  SafaSession? _session;
  SafaSession? get session => _session;

  bool _sending = false;

  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void _set(SafaSession? next) {
    _session = next;
    _notify();
  }

  /// Open a contextual session. Deep link without valid origin → treat as Today return.
  void open({
    required SafaSessionOrigin origin,
    String? returnPath,
    String locale = 'en',
    String? view,
  }) {
    final safeOrigin = SafaEligibility.allowsExplicitOrigin(origin)
        ? origin
        : SafaSessionOrigin.today;
    final path = returnPath?.trim().isNotEmpty == true
        ? returnPath!.trim()
        : safeOrigin.defaultReturnPath;

    final now = _clock();
    final noticeOk = _consentStore.aiNoticeAcknowledged;
    final consent = noticeOk
        ? SafaConsentState.consentRequired
        : SafaConsentState.noticeRequired;

    SafaSessionState ui;
    if (view == 'privacy') {
      ui = SafaSessionState.privacyNotice;
    } else if (view == 'unavailable') {
      ui = SafaSessionState.localFallback;
    } else if (view == 'urgent') {
      ui = SafaSessionState.safetyRedirect;
    } else if (!noticeOk) {
      ui = SafaSessionState.privacyNotice;
    } else {
      ui = SafaSessionState.consentRequired;
    }

    final session = SafaSession(
      id: SafaSessionId.create(now),
      origin: safeOrigin,
      returnPath: path,
      locale: locale == 'ar' ? 'ar' : 'en',
      consentState: consent,
      uiState: ui,
      userMessageCount: 0,
      assistantResponseCount: 0,
      draftMessage: '',
      contextCategory: SafaContextCategory.none,
      includeApprovedContext: false,
      createdAt: now,
      updatedAt: now,
      initialView: view,
    );

    if (ui == SafaSessionState.localFallback) {
      _set(
        session.copyWith(
          latestResponse: SafaLocalFallback.build(
            sessionId: session.id,
            locale: session.locale,
            generatedAt: now,
          ),
          updatedAt: now,
        ),
      );
      return;
    }

    _set(session);
  }

  void acknowledgePrivacyNotice() {
    final s = _session;
    if (s == null) return;
    _consentStore.acknowledgeAiNotice();
    _set(
      s.copyWith(
        consentState: SafaConsentState.consentRequired,
        uiState: SafaSessionState.consentRequired,
        updatedAt: _clock(),
        clearInitialView: true,
      ),
    );
  }

  void grantSendConsent() {
    final s = _session;
    if (s == null) return;
    _set(
      s.copyWith(
        consentState: SafaConsentState.granted,
        uiState: SafaSessionState.ready,
        updatedAt: _clock(),
      ),
    );
  }

  /// Decline network Safa — keep local fallback available.
  void declineConsent() {
    final s = _session;
    if (s == null) return;
    final now = _clock();
    final fallback = SafaLocalFallback.build(
      sessionId: s.id,
      locale: s.locale,
      generatedAt: now,
    );
    _set(
      s.copyWith(
        consentState: SafaConsentState.declined,
        uiState: SafaSessionState.localFallback,
        latestResponse: fallback,
        updatedAt: now,
      ),
    );
  }

  void updateDraft(String text) {
    final s = _session;
    if (s == null || s.uiState == SafaSessionState.sending) return;
    final tooLong =
        SafaRequestMapper.normalizeMessage(text).length >
            SafaSessionLimit.maxInputCharacters;
    _set(
      s.copyWith(
        draftMessage: text,
        uiState: tooLong
            ? SafaSessionState.inputTooLong
            : (s.uiState == SafaSessionState.inputTooLong
                ? SafaSessionState.ready
                : s.uiState),
        failureReason: tooLong
            ? SafaFailureReason.inputTooLong
            : SafaFailureReason.none,
        updatedAt: _clock(),
      ),
    );
  }

  void selectContextCategory(SafaContextCategory category) {
    final s = _session;
    if (s == null) return;
    _set(
      s.copyWith(
        contextCategory: category,
        updatedAt: _clock(),
      ),
    );
  }

  void setIncludeApprovedContext(bool include) {
    final s = _session;
    if (s == null) return;
    _set(
      s.copyWith(
        includeApprovedContext: include,
        clearApprovedContextSummary: !include,
        clearApprovedStepTitle: !include,
        updatedAt: _clock(),
      ),
    );
  }

  void setApprovedContextSummary(String? summary) {
    final s = _session;
    if (s == null || !s.includeApprovedContext) return;
    _set(
      s.copyWith(
        approvedContextSummary: summary,
        updatedAt: _clock(),
      ),
    );
  }

  void setApprovedStepTitle(String? title) {
    final s = _session;
    if (s == null || !s.includeApprovedContext) return;
    _set(
      s.copyWith(
        approvedStepTitle: title,
        updatedAt: _clock(),
      ),
    );
  }

  Future<void> send() async {
    final s = _session;
    if (s == null || _sending) return;

    if (s.isBoundReached ||
        s.userMessageCount >= SafaSessionLimit.maxUserMessages) {
      _set(
        s.copyWith(
          uiState: SafaSessionState.boundedSessionComplete,
          failureReason: SafaFailureReason.sessionBoundReached,
          updatedAt: _clock(),
        ),
      );
      return;
    }

    final normalized = SafaRequestMapper.normalizeMessage(s.draftMessage);
    if (normalized.isEmpty) {
      _set(
        s.copyWith(
          failureReason: SafaFailureReason.emptyInput,
          updatedAt: _clock(),
        ),
      );
      return;
    }
    if (SafaRequestMapper.isTooLong(s.draftMessage)) {
      _set(
        s.copyWith(
          uiState: SafaSessionState.inputTooLong,
          failureReason: SafaFailureReason.inputTooLong,
          updatedAt: _clock(),
        ),
      );
      return;
    }

    if (s.consentState == SafaConsentState.noticeRequired) {
      _set(
        s.copyWith(
          uiState: SafaSessionState.privacyNotice,
          failureReason: SafaFailureReason.consentRequired,
          updatedAt: _clock(),
        ),
      );
      return;
    }
    if (s.consentState == SafaConsentState.consentRequired) {
      _set(
        s.copyWith(
          uiState: SafaSessionState.consentRequired,
          failureReason: SafaFailureReason.consentRequired,
          updatedAt: _clock(),
        ),
      );
      return;
    }
    if (s.consentState == SafaConsentState.declined) {
      await useLocalFallback();
      return;
    }

    _sending = true;
    final sendingSession = s.copyWith(
      uiState: SafaSessionState.sending,
      userMessageCount: s.userMessageCount + 1,
      draftMessage: normalized,
      failureReason: SafaFailureReason.none,
      updatedAt: _clock(),
    );
    _set(sendingSession);

    final request = SafaRequest(
      sessionId: sendingSession.id,
      message: normalized,
      locale: sendingSession.locale,
      origin: sendingSession.origin,
      contextCategory: sendingSession.contextCategory,
      approvedContextSummary: sendingSession.includeApprovedContext
          ? sendingSession.approvedContextSummary
          : null,
      approvedStepTitle: sendingSession.includeApprovedContext
          ? sendingSession.approvedStepTitle
          : null,
    );

    try {
      final result = await _edge.send(request);
      final current = _session;
      if (current == null || current.id != sendingSession.id) return;

      if (!result.isOk || result.response == null) {
        _applyFailure(current, result.failure);
        return;
      }

      final assistantCount = current.assistantResponseCount + 1;
      final bound = assistantCount >= SafaSessionLimit.maxAssistantResponses ||
          current.userMessageCount >= SafaSessionLimit.maxUserMessages;

      _set(
        current.copyWith(
          uiState: bound
              ? SafaSessionState.boundedSessionComplete
              : SafaSessionState.responseReady,
          assistantResponseCount: assistantCount,
          latestResponse: result.response,
          failureReason: SafaFailureReason.none,
          // Keep draft for retry clarity only on failure; clear after success.
          draftMessage: '',
          updatedAt: _clock(),
        ),
      );
    } catch (_) {
      final current = _session;
      if (current == null) return;
      // Never surface exception text / message content.
      _applyFailure(current, SafaFailureReason.unknown);
    } finally {
      _sending = false;
    }
  }

  void _applyFailure(SafaSession current, SafaFailureReason reason) {
    final now = _clock();
    final fallback = SafaLocalFallback.build(
      sessionId: current.id,
      locale: current.locale,
      generatedAt: now,
    );

    final ui = switch (reason) {
      SafaFailureReason.timeout => SafaSessionState.timeout,
      SafaFailureReason.offline => SafaSessionState.offline,
      SafaFailureReason.serverError ||
      SafaFailureReason.missingConfig ||
      SafaFailureReason.notInitialized =>
        SafaSessionState.serviceUnavailable,
      SafaFailureReason.invalidResponse ||
      SafaFailureReason.malformedResponse ||
      SafaFailureReason.emptyReply =>
        SafaSessionState.invalidResponse,
      _ => SafaSessionState.localFallback,
    };

    // Decrement user count on failed network so a retry still counts once?
    // Contract: preserve draft; turn was attempted. Keep count (attempt used).
    _set(
      current.copyWith(
        uiState: ui,
        failureReason: reason,
        latestResponse: fallback,
        updatedAt: now,
      ),
    );
  }

  Future<void> useLocalFallback() async {
    final s = _session;
    if (s == null) return;
    final now = _clock();
    _set(
      s.copyWith(
        uiState: SafaSessionState.localFallback,
        latestResponse: SafaLocalFallback.build(
          sessionId: s.id,
          locale: s.locale,
          generatedAt: now,
        ),
        updatedAt: now,
      ),
    );
  }

  Future<void> retry() async {
    final s = _session;
    if (s == null) return;
    if (s.consentState != SafaConsentState.granted) {
      if (s.consentState == SafaConsentState.declined) {
        await useLocalFallback();
        return;
      }
      return;
    }
    // Restore ready so send can run; preserve draft.
    _set(
      s.copyWith(
        uiState: SafaSessionState.ready,
        failureReason: SafaFailureReason.none,
        // Undo failed attempt count so retry is the same turn.
        userMessageCount: s.userMessageCount > 0 &&
                s.uiState != SafaSessionState.responseReady &&
                s.uiState != SafaSessionState.boundedSessionComplete
            ? s.userMessageCount - 1
            : s.userMessageCount,
        updatedAt: _clock(),
      ),
    );
    await send();
  }

  void requestUrgentHelp() {
    final s = _session;
    if (s == null) return;
    _set(
      s.copyWith(
        uiState: SafaSessionState.safetyRedirect,
        failureReason: SafaFailureReason.none,
        updatedAt: _clock(),
      ),
    );
  }

  void cancelSend() {
    final s = _session;
    if (s == null) return;
    _set(
      s.copyWith(
        uiState: SafaSessionState.userCancelled,
        updatedAt: _clock(),
      ),
    );
  }

  void clearSession() {
    final s = _session;
    if (s == null) {
      _set(null);
      return;
    }
    final now = _clock();
    _set(
      s.copyWith(
        uiState: SafaSessionState.cleared,
        draftMessage: '',
        contextCategory: SafaContextCategory.none,
        includeApprovedContext: false,
        clearApprovedContextSummary: true,
        clearApprovedStepTitle: true,
        clearLatestResponse: true,
        userMessageCount: 0,
        assistantResponseCount: 0,
        failureReason: SafaFailureReason.none,
        updatedAt: now,
      ),
    );
    // Fully drop in-memory session after clear signal.
    _set(null);
  }

  /// Start a fresh clean session with the same origin (after bound / clear).
  void startNewSessionLater() {
    final s = _session;
    final origin = s?.origin ?? SafaSessionOrigin.today;
    final returnPath = s?.returnPath;
    final locale = s?.locale ?? 'en';
    clearSession();
    open(origin: origin, returnPath: returnPath, locale: locale);
  }
}
