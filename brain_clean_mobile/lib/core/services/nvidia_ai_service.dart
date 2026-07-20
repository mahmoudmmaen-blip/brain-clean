import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// هذا السطر هو مفتاح الربط مع Riverpod
final nvidiaAiServiceProvider = Provider<NvidiaAiService>((ref) => NvidiaAiService());

class NvidiaAiService {
  static const String _endpoint =
      'https://integrate.api.nvidia.com/v1/chat/completions';
  static const String _fallbackMessage =
      'عذراً، صفا غير متاحة الآن. حاول مرة أخرى لاحقاً.';

  /// Read lazily so dotenv is guaranteed loaded before first access.
  String get _apiKey => dotenv.env['NVIDIA_API_KEY'] ?? '';

  static const String _systemPrompt = '''
أنت صفا، المساعدة الذكية في تطبيق Brain Clean.
تتكلمي دايماً بالعامية المصرية زي أهل القاهرة.
ردودك قصيرة (3 جمل بس).
تكوني حنونة وقريبة زي صاحبة مقربة.
لا تستخدمي كلمات مغربية أو خليجية أو فصحى.
أمثلة على أسلوبك: "ايه اللي بيضايقك؟"، "أنا معاكي"، "مش لوحدك في ده".
''';

  Future<String> analyzeEmotion(String userText) async {
    final response = await chat(
      systemPrompt: _systemPrompt,
      userMessage: userText,
    );
    return response ?? _fallbackMessage;
  }

  /// Returns AI text or `null` when the key is missing / the request fails.
  Future<String?> chat({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (_apiKey.isEmpty) return null;

    debugPrint('SAFA_DEBUG: apiKey length = ${_apiKey.length}');
    debugPrint(
      'SAFA_DEBUG: apiKey first 8 = ${_apiKey.length > 8 ? _apiKey.substring(0, 8) : "TOO_SHORT"}',
    );
    debugPrint('SAFA_DEBUG: message = $userMessage');

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'nvidia/llama-3.1-nemotron-70b-instruct',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.7,
              'max_tokens': 300,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('SAFA_ERROR: status=${response.statusCode}');
        debugPrint('SAFA_ERROR: body=${response.body}');
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices']?[0]?['message']?['content'];
      if (content == null) {
        debugPrint('NvidiaAiService: unexpected response shape');
        return null;
      }
      return content.toString().trim();
    } catch (e) {
      if (response != null) {
        debugPrint('SAFA_ERROR: status=${response.statusCode}');
        debugPrint('SAFA_ERROR: body=${response.body}');
      }
      debugPrint('SAFA_DEBUG: error = $e');
      debugPrint('NvidiaAiService: request failed: $e');
      return null;
    }
  }
}