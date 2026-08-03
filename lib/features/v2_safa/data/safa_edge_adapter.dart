import '../../../core/services/claude_ai_service.dart';
import '../domain/safa_failure_reason.dart';
import '../domain/safa_request.dart';
import '../domain/safa_request_mapper.dart';
import '../domain/safa_response.dart';
import '../domain/safa_response_validator.dart';
import '../domain/safa_session_id.dart';
import '../domain/safa_session_limit.dart';

/// Outcome of a V2 Safa Edge call.
class SafaEdgeResult {
  const SafaEdgeResult.ok(this.response)
      : failure = SafaFailureReason.none,
        rawData = null;

  const SafaEdgeResult.fail(this.failure, {this.rawData}) : response = null;

  final SafaResponse? response;
  final SafaFailureReason failure;
  final Object? rawData;

  bool get isOk => response != null && failure == SafaFailureReason.none;
}

/// Adapts existing `safa-chat` Edge transport without redesign.
class SafaEdgeAdapter {
  SafaEdgeAdapter({
    required ClaudeAiService claude,
    DateTime Function()? clock,
    bool Function()? isOnline,
  })  : _claude = claude,
        _clock = clock ?? (() => DateTime.now().toUtc()),
        _isOnline = isOnline ?? (() => true);

  final ClaudeAiService _claude;
  final DateTime Function() _clock;
  final bool Function() _isOnline;

  Future<SafaEdgeResult> send(SafaRequest request) async {
    if (!_isOnline()) {
      return const SafaEdgeResult.fail(SafaFailureReason.offline);
    }

    final body = SafaRequestMapper.toAllowlistedBody(request);
    if (body == null) {
      final empty = SafaRequestMapper.isEmpty(request.message);
      return SafaEdgeResult.fail(
        empty ? SafaFailureReason.emptyInput : SafaFailureReason.inputTooLong,
      );
    }
    if (!SafaRequestMapper.isAllowlisted(body)) {
      return const SafaEdgeResult.fail(SafaFailureReason.invalidResponse);
    }

    // Preserve 30s timeout; ClaudeAiService already enforces it.
    assert(_claude.timeout == SafaSessionLimit.edgeTimeout ||
        _claude.timeout.inSeconds == 30);

    final outcome = await _claude.sendAllowlisted(body);
    return _mapOutcome(outcome, request.sessionId);
  }

  SafaEdgeResult _mapOutcome(SafaChatOutcome outcome, SafaSessionId sessionId) {
    if (!outcome.isSuccess) {
      return SafaEdgeResult.fail(_mapFailure(outcome));
    }

    final generatedAt = _clock();
    final validated = SafaResponseValidator.fromEdgePayload(
      data: {
        'reply': outcome.reply,
        if (outcome.httpStatus != null) 'httpStatus': outcome.httpStatus,
      },
      sessionId: sessionId,
      generatedAt: generatedAt,
    );

    if (validated == null) {
      return const SafaEdgeResult.fail(SafaFailureReason.invalidResponse);
    }
    return SafaEdgeResult.ok(validated);
  }

  SafaFailureReason _mapFailure(SafaChatOutcome outcome) {
    switch (outcome.failure) {
      case SafaChatFailureKind.missingConfig:
        return SafaFailureReason.missingConfig;
      case SafaChatFailureKind.notInitialized:
        return SafaFailureReason.notInitialized;
      case SafaChatFailureKind.timeout:
        return SafaFailureReason.timeout;
      case SafaChatFailureKind.serverError:
        return SafaFailureReason.serverError;
      case SafaChatFailureKind.malformedResponse:
        return SafaFailureReason.malformedResponse;
      case SafaChatFailureKind.emptyReply:
        return SafaFailureReason.emptyReply;
      case SafaChatFailureKind.network:
        return SafaFailureReason.network;
      case SafaChatFailureKind.unknown:
      case null:
        return SafaFailureReason.unknown;
    }
  }
}
