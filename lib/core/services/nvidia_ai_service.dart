import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// هذا السطر هو مفتاح الربط مع Riverpod
final nvidiaAiServiceProvider = Provider<NvidiaAiService>((ref) => NvidiaAiService());

class NvidiaAiService {
  static const String _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';
  static const int _maxUserTextLength = 2000;
  static const String _defineKey = String.fromEnvironment('NVIDIA_API_KEY');

  /// `--dart-define` first (release-safe); dotenv is a local-dev fallback only.
  String get _apiKey {
    if (_defineKey.trim().isNotEmpty) return _defineKey.trim();
    try {
      return dotenv.env['NVIDIA_API_KEY']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> analyzeEmotion(String userText) async {
    final key = _apiKey;
    if (key.isEmpty) return "يرجى ضبط مفتاح الـ API في ملف .env.";

    final message = userText.trim();
    if (message.isEmpty) return "اكتب ما تشعر به أولاً.";
    final prompt = message.length > _maxUserTextLength
        ? message.substring(0, _maxUserTextLength)
        : message;

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          "model": "meta/llama3-70b-instruct",
          "messages": [
            {"role": "system", "content": "أنت مرشد سلوكي في تطبيق (Pure Day). قدم نصيحة عملية، صارمة، وداعمة. ممنوع الموسيقى. ركز على التنفس، الرياضة، أو التدوين."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.5,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      }
      return "تعذر الوصول للمرشد الآن، حاول مرة أخرى.";
    } catch (_) {
      return "تعذر الاتصال بالإنترنت، حاول مرة أخرى.";
    }
  }
}
