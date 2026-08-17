import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// هذا السطر هو مفتاح الربط مع Riverpod
final nvidiaAiServiceProvider = Provider<NvidiaAiService>((ref) => NvidiaAiService());

class NvidiaAiService {
  final String _apiKey = dotenv.env['NVIDIA_API_KEY'] ?? ''; 
  static const String _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';

  /// Throws [NvidiaAiException] when the coaching reply cannot be produced.
  Future<String> analyzeEmotion(String userText) async {
    if (_apiKey.isEmpty) {
      throw NvidiaAiException("يرجى ضبط مفتاح الـ API في ملف .env.");
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
            {"role": "system", "content": "أنت مرشد سلوكي في تطبيق (Pure Day). قدم نصيحة عملية، صارمة، وداعمة. ممنوع الموسيقى. ركز على التنفس، الرياضة، أو التدوين."},
            {"role": "user", "content": userText}
          ],
          "temperature": 0.5,
          "max_tokens": 150,
        }),
      );

      if (response.statusCode != 200) {
        throw NvidiaAiException(
          "خطأ في السيرفر: ${response.statusCode}",
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].toString().trim();
    } on NvidiaAiException {
      rethrow;
    } catch (error, stackTrace) {
      throw NvidiaAiException(
        "خطأ في الاتصال بالمرشد — حاول مرة أخرى.",
        cause: error,
        causeStackTrace: stackTrace,
      );
    }
  }
}

/// Coaching request failure — [message] is safe to show to the user.
class NvidiaAiException implements Exception {
  NvidiaAiException(
    this.message, {
    this.cause,
    this.causeStackTrace,
    this.statusCode,
  });

  final String message;
  final Object? cause;
  final StackTrace? causeStackTrace;
  final int? statusCode;

  @override
  String toString() => cause == null ? message : '$message (cause: $cause)';
}
