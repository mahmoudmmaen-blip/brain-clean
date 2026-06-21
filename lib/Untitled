import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nvidiaAiServiceProvider = Provider<NvidiaAiService>((ref) {
  return NvidiaAiService();
});

class NvidiaAiService {
  static const String _apiKey = 'YOUR_NVIDIA_API_KEY_HERE'; 
  static const String _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';

  Future<String> analyzeEmotion(String userText) async {
    if (_apiKey.contains('YOUR_NVIDIA_API_KEY_HERE') || _apiKey.isEmpty) {
      return _getSafeFallbackResponse();
    }

    try {
      final response = await http.post(
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
              "content": "أنت مرشد سلوكي في تطبيق (Pure Day). قدم نصيحة عملية، صارمة، وداعمة. ممنوع الموسيقى. ركز على التنفس، الرياضة، أو التدوين."
            },
            {"role": "user", "content": userText}
          ],
          "temperature": 0.5,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      }
      return _getSafeFallbackResponse();
    } catch (e) {
      return _getSafeFallbackResponse();
    }
  }

  String _getSafeFallbackResponse() {
    return "أحسنت بطلبك للمساعدة. تذكر يا بطل أن التعافي رحلة، وكل لحظة تقاوم فيها هي انتصار. ركز على تنفسك، وابتعد عن المشتتات فوراً. أنت أقوى من أي رغبة لحظية.";
  }
}