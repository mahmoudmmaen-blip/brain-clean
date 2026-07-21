import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClaudeAiService {
  String get _apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  Future<String?> chat(String userMessage) async {
    if (_apiKey.isEmpty) return null;
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5',
          'max_tokens': 300,
          'system': '''أنت صفا، مساعدة دعم نفسي في تطبيق Brain Clean.
قواعدك:
١. أول رد: اعترف بالمشاعر بجملة واحدة حنينة زي "ده صعب فعلاً" أو "أنا فاهماكي"
٢. اسأل سؤال واحد بس عشان تفهم أكتر
٣. بعد ما تفهم: اقترح حاجة واحدة عملية من التطبيق (سكون / دفتر القلق / تنفس)
٤. كلامك بالعامية المصرية دايماً - مش فصحى مش خليجي مش مغربي
٥. مش أكتر من 3 جمل في كل رد
٦. لو حد بيقول كلام خطير قولي: "ده مهم - كلم حد قريب منك دلوقتي"''',
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );
      debugPrint('CLAUDE_DEBUG: status=${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content']?[0]?['text']?.toString().trim();
      }
      debugPrint('CLAUDE_DEBUG: error body=${response.body}');
      return null;
    } catch (e) {
      debugPrint('CLAUDE_DEBUG: exception=$e');
      return null;
    }
  }
}
