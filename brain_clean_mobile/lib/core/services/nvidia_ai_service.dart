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

  Future<String> analyzeEmotion(String userText) async {
    final response = await chat(
      systemPrompt:
          'أنت صفا، مرشدك في تطبيق Brain Clean. مهمتك مساعدة المستخدم على التعافي من إدمان الشاشات وإعادة بناء التركيز. قدّم نصيحة عملية وداعمة. ممنوع الموسيقى. ركز على التنفس، الرياضة، التدوين، وتقليل وقت الشاشة.',
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

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'meta/llama3-70b-instruct',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.5,
              'max_tokens': 250,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint(
          'NvidiaAiService: request failed with status ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices']?[0]?['message']?['content'];
      if (content == null) {
        debugPrint('NvidiaAiService: unexpected response shape');
        return null;
      }
      return content.toString().trim();
    } catch (error) {
      debugPrint('NvidiaAiService: request failed: $error');
      return null;
    }
  }
}