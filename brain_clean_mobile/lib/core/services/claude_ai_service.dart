import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final claudeAiServiceProvider =
    Provider<ClaudeAiService>((ref) => ClaudeAiService());

class ClaudeAiService {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String fallbackMessage =
      'أنا هنا معاك — جرّب تاني بعد شوية 🌿';

  /// Read lazily so dotenv is guaranteed loaded before first access.
  String get _apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  static const String _systemPrompt = '''
أنت صفا، مساعدة دعم نفسي في تطبيق Brain Clean.
قواعدك:
١. أول رد: اعترف بالمشاعر بجملة واحدة حنينة
٢. اسأل سؤال واحد بس عشان تفهم أكتر
٣. بعد ما تفهم: اقترح حاجة واحدة عملية من التطبيق
٤. كلامك بالعامية المصرية دايماً
٥. مش أكتر من 3 جمل في كل رد
٦. لو حد بيقول كلام خطير قولي: "ده مهم — كلم حد قريب منك دلوقتي"
''';

  /// Returns AI text, fallback on default-prompt errors, or `null` for custom prompts.
  Future<String?> chat(String message, {String? systemPrompt}) async {
    final useServiceFallback = systemPrompt == null;
    if (_apiKey.isEmpty) {
      return useServiceFallback ? fallbackMessage : null;
    }

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': 'claude-haiku-4-5',
              'max_tokens': 300,
              'system': systemPrompt ?? _systemPrompt,
              'messages': [
                {'role': 'user', 'content': message},
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('ClaudeAiService: status=${response.statusCode}');
        debugPrint('ClaudeAiService: body=${response.body}');
        return useServiceFallback ? fallbackMessage : null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['content'];
      if (content is List && content.isNotEmpty) {
        final text = content[0]['text'];
        if (text != null) return text.toString().trim();
      }

      debugPrint('ClaudeAiService: unexpected response shape');
      return useServiceFallback ? fallbackMessage : null;
    } catch (e) {
      if (response != null) {
        debugPrint('ClaudeAiService: status=${response.statusCode}');
        debugPrint('ClaudeAiService: body=${response.body}');
      }
      debugPrint('ClaudeAiService: request failed: $e');
      return useServiceFallback ? fallbackMessage : null;
    }
  }
}
