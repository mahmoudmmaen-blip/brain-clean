import 'safa_context_category.dart';
import 'safa_request.dart';
import 'safa_session_limit.dart';
import 'safa_session_origin.dart';

/// Maps a [SafaRequest] to the Edge allowlist body (Contract §7.3).
///
/// Never includes Score, Profile, Check answers, Weekly Review, Reports,
/// purchase data, or prior Safa history.
abstract final class SafaRequestMapper {
  /// Forbidden keys that must never appear in the outbound body.
  static const forbiddenKeys = <String>{
    'brainCheck',
    'answers',
    'profile',
    'profilePack',
    'recoveryScore',
    'score',
    'reflection',
    'weeklyReview',
    'weeklyArtifact',
    'reports',
    'notes',
    'setback',
    'purchase',
    'subscription',
    'entitlement',
    'history',
    'hive',
    'userId',
    'email',
    'deviceId',
  };

  static String normalizeMessage(String raw) {
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool isEmpty(String raw) => normalizeMessage(raw).isEmpty;

  static bool isTooLong(String raw) =>
      normalizeMessage(raw).length > SafaSessionLimit.maxInputCharacters;

  /// Build allowlisted body. Omits optional nulls. Rejects empty / oversized.
  static Map<String, dynamic>? toAllowlistedBody(SafaRequest request) {
    final message = normalizeMessage(request.message);
    if (message.isEmpty) return null;
    if (message.length > SafaSessionLimit.maxInputCharacters) return null;

    final body = <String, dynamic>{
      'message': message,
      'locale': request.locale == 'ar' ? 'ar' : 'en',
      'origin': request.origin.wireId,
      'sessionToken': request.sessionId.value,
    };

    final category = request.contextCategory.wireId;
    if (category != null) {
      body['contextCategory'] = category;
    }

    final summary = request.approvedContextSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      body['approvedContextSummary'] = summary.length > 200
          ? summary.substring(0, 200)
          : summary;
    }

    final step = request.approvedStepTitle?.trim();
    if (step != null && step.isNotEmpty) {
      body['approvedStepTitle'] =
          step.length > 120 ? step.substring(0, 120) : step;
    }

    // Defense: strip any accidental forbidden keys.
    for (final key in forbiddenKeys) {
      body.remove(key);
    }
    return body;
  }

  /// True when [body] contains only allowlisted keys.
  static bool isAllowlisted(Map<String, dynamic> body) {
    const allowed = {
      'message',
      'locale',
      'origin',
      'contextCategory',
      'approvedContextSummary',
      'approvedStepTitle',
      'sessionToken',
    };
    for (final key in body.keys) {
      if (!allowed.contains(key)) return false;
      if (forbiddenKeys.contains(key)) return false;
    }
    if (!body.containsKey('message')) return false;
    return true;
  }
}
