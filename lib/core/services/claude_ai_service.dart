import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Categories for Safa chat failures (safe to log — no secrets / message text).
enum SafaChatFailureKind {
  missingConfig,
  notInitialized,
  timeout,
  serverError,
  malformedResponse,
  emptyReply,
  network,
  unknown,
}

/// Outcome of a Safa chat request.
@immutable
class SafaChatOutcome {
  const SafaChatOutcome.success(this.reply)
      : failure = null,
        httpStatus = null,
        timedOut = false;

  const SafaChatOutcome.failure(
    this.failure, {
    this.httpStatus,
    this.timedOut = false,
  }) : reply = null;

  final String? reply;
  final SafaChatFailureKind? failure;
  final int? httpStatus;
  final bool timedOut;

  bool get isSuccess =>
      reply != null && reply!.trim().isNotEmpty && failure == null;
}

/// Invokes the Supabase Edge Function for Safa (test seam).
typedef SafaFunctionInvoker = Future<FunctionResponse> Function({
  required String functionName,
  required Map<String, dynamic> body,
});

/// Calls Supabase Edge Function `safa-chat` (Claude runs server-side only).
class ClaudeAiService {
  ClaudeAiService({
    SafaFunctionInvoker? invoker,
    this.timeout = const Duration(seconds: 30),
    @visibleForTesting bool? supabaseConfigured,
    @visibleForTesting bool? supabaseInitialized,
  })  : _invoker = invoker,
        _supabaseConfiguredOverride = supabaseConfigured,
        _supabaseInitializedOverride = supabaseInitialized;

  static const functionName = 'safa-chat';

  final SafaFunctionInvoker? _invoker;
  final Duration timeout;
  final bool? _supabaseConfiguredOverride;
  final bool? _supabaseInitializedOverride;

  /// Last debug diagnostic line (debug builds / tests only). Never includes
  /// user message text, keys, tokens, headers, or full server bodies.
  @visibleForTesting
  static String? lastDebugDiagnostic;

  /// Convenience wrapper used by callers that only need the reply string.
  Future<String?> chat(String userMessage) async {
    final outcome = await send(userMessage);
    return outcome.reply;
  }

  /// Legacy message-only send — preserved for Emotion Oasis compatibility.
  Future<SafaChatOutcome> send(String userMessage) async {
    return sendAllowlisted({'message': userMessage});
  }

  /// Allowlisted Edge invoke (Contract §7.3 / §14). No client Claude secret.
  ///
  /// Callers must supply only allowlisted keys. Raw recovery payloads are
  /// never added here.
  Future<SafaChatOutcome> sendAllowlisted(Map<String, dynamic> body) async {
    lastDebugDiagnostic = null;

    if (!_isSupabaseConfigured) {
      _debugLog(
        kind: SafaChatFailureKind.missingConfig,
        timedOut: false,
      );
      return const SafaChatOutcome.failure(SafaChatFailureKind.missingConfig);
    }

    if (!_isSupabaseInitialized) {
      _debugLog(
        kind: SafaChatFailureKind.notInitialized,
        timedOut: false,
      );
      return const SafaChatOutcome.failure(SafaChatFailureKind.notInitialized);
    }

    try {
      final invoker = _invoker ?? _defaultInvoker;
      final res = await invoker(
        functionName: functionName,
        body: body,
      ).timeout(timeout);

      final status = res.status;
      if (status >= 400) {
        _debugLog(
          kind: SafaChatFailureKind.serverError,
          httpStatus: status,
          timedOut: false,
        );
        return SafaChatOutcome.failure(
          SafaChatFailureKind.serverError,
          httpStatus: status,
        );
      }

      final data = res.data;
      if (data is! Map) {
        _debugLog(
          kind: SafaChatFailureKind.malformedResponse,
          httpStatus: status,
          timedOut: false,
        );
        return SafaChatOutcome.failure(
          SafaChatFailureKind.malformedResponse,
          httpStatus: status,
        );
      }

      final replyRaw = data['reply'];
      if (replyRaw is! String) {
        // Edge may return HTTP 200 with {reply: null} when Claude fails.
        _debugLog(
          kind: SafaChatFailureKind.emptyReply,
          httpStatus: status,
          timedOut: false,
        );
        return SafaChatOutcome.failure(
          SafaChatFailureKind.emptyReply,
          httpStatus: status,
        );
      }

      final reply = replyRaw.trim();
      if (reply.isEmpty) {
        _debugLog(
          kind: SafaChatFailureKind.emptyReply,
          httpStatus: status,
          timedOut: false,
        );
        return SafaChatOutcome.failure(
          SafaChatFailureKind.emptyReply,
          httpStatus: status,
        );
      }

      return SafaChatOutcome.success(reply);
    } on TimeoutException {
      _debugLog(kind: SafaChatFailureKind.timeout, timedOut: true);
      return const SafaChatOutcome.failure(
        SafaChatFailureKind.timeout,
        timedOut: true,
      );
    } on FunctionException catch (error) {
      _debugLog(
        kind: SafaChatFailureKind.serverError,
        httpStatus: error.status,
        timedOut: false,
      );
      return SafaChatOutcome.failure(
        SafaChatFailureKind.serverError,
        httpStatus: error.status,
      );
    } catch (_) {
      _debugLog(kind: SafaChatFailureKind.network, timedOut: false);
      return const SafaChatOutcome.failure(SafaChatFailureKind.network);
    }
  }

  bool get _isSupabaseConfigured =>
      _supabaseConfiguredOverride ?? AppConfig.hasValidSupabaseConfig;

  bool get _isSupabaseInitialized {
    if (_supabaseInitializedOverride != null) {
      return _supabaseInitializedOverride!;
    }
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static Future<FunctionResponse> _defaultInvoker({
    required String functionName,
    required Map<String, dynamic> body,
  }) {
    return Supabase.instance.client.functions.invoke(
      functionName,
      body: body,
    );
  }

  static void _debugLog({
    required SafaChatFailureKind kind,
    int? httpStatus,
    required bool timedOut,
  }) {
    if (!kDebugMode) return;
    final statusPart = httpStatus == null ? 'none' : '$httpStatus';
    final line =
        'SafaChat: kind=$kind function=$functionName '
        'httpStatus=$statusPart timedOut=$timedOut';
    lastDebugDiagnostic = line;
    debugPrint(line);
  }
}
