import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🚨 ملاحظة: لو السطر ده تحته خط أحمر، امسحه واضغط (Ctrl + .) على كلمة nvidiaAiServiceProvider تحت واختار Import library
import 'package:brain_clean_mobile/core/diagnostics/app_error_logger.dart';
import 'package:brain_clean_mobile/core/services/nvidia_ai_service.dart';

class EmotionOasisScreen extends ConsumerStatefulWidget {
  const EmotionOasisScreen({super.key});

  @override
  ConsumerState<EmotionOasisScreen> createState() => _EmotionOasisScreenState();
}

class _EmotionOasisScreenState extends ConsumerState<EmotionOasisScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _analyze() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
      _errorMessage = '';
    });

    // إخفاء الكيبورد أثناء التحليل
    FocusScope.of(context).unfocus();

    final service = ref.read(nvidiaAiServiceProvider);
    try {
      final result = await service.analyzeEmotion(_controller.text);
      if (!mounted) return;
      setState(() {
        _response = result;
        _isLoading = false;
      });
    } on NvidiaAiException catch (error, stackTrace) {
      logAppError('EmotionOasisScreen._analyze', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      logAppError('EmotionOasisScreen._analyze', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع — حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('واحة المشاعر - Brain Clean')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تحدث مع المرشد السلوكي.. ما الذي تواجهه الآن؟',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب مشاعرك أو التحدي بكل صراحة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Text(
                      'تحليل وطلب الدعم', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_response.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _response,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}