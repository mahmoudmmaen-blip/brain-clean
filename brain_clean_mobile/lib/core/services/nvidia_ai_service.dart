import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// هذا السطر هو مفتاح الربط مع Riverpod
final nvidiaAiServiceProvider = Provider<NvidiaAiService>((ref) => NvidiaAiService());

class NvidiaAiService {
  final String _apiKey = dotenv.env['NVIDIA_API_KEY'] ?? '';
  static const String _endpoint =
      'https://integrate.api.nvidia.com/v1/chat/completions';
  static const String _fallbackMessage =
      'عذراً، صفا غير متاحة الآن. حاول مرة أخرى لاحقاً.';

  Future<String> analyzeEmotion(String userText) async {
    if (_apiKey.isEmpty) return "يرجى ضبط مفتاح الـ API في ملف .env.";

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              "model": "meta/llama3-70b-instruct",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "أنت صفا، مرشدك في تطبيق Brain Clean. مهمتك مساعدة المستخدم على التعافي من إدمان الشاشات وإعادة بناء التركيز. قدّم نصيحة عملية وداعمة. ممنوع الموسيقى. ركز على التنفس، الرياضة، التدوين، وتقليل وقت الشاشة."
                },
                {"role": "user", "content": userText}
              ],
              "temperature": 0.5,
              "max_tokens": 150,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint(
          'NvidiaAiService: request failed with status ${response.statusCode}',
        );
        return _fallbackMessage;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices']?[0]?['message']?['content'];
      if (content == null) {
        debugPrint('NvidiaAiService: unexpected response shape');
        return _fallbackMessage;
      }
      return content.toString().trim();
    } catch (error) {
      debugPrint('NvidiaAiService: request failed: $error');
      return _fallbackMessage;
    }
  }
}