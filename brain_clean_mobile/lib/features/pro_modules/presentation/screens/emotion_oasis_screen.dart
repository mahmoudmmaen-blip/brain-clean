import 'package:brain_clean_mobile/core/services/claude_ai_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../pro/pro_paywall_screen.dart';
import '../../../safa_tab/application/safa_trial_provider.dart';
import '../../../safa_tab/presentation/widgets/safa_medical_disclaimer.dart';

class EmotionOasisScreen extends ConsumerStatefulWidget {
  const EmotionOasisScreen({super.key});

  @override
  ConsumerState<EmotionOasisScreen> createState() => _EmotionOasisScreenState();
}

class _EmotionOasisScreenState extends ConsumerState<EmotionOasisScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(safaTrialControllerProvider.notifier).recordFirstVisitIfNeeded();
    });
  }

  Future<void> _analyze() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    FocusScope.of(context).unfocus();

    final loc = AppLocalizations.of(context)!;
    final service = ref.read(claudeAiServiceProvider);
    final outcome = await service.send(_controller.text.trim());

    if (!mounted) return;

    setState(() {
      _response = outcome.isSuccess
          ? outcome.reply!
          : loc.safaTemporarilyUnavailable;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accessAllowed = ref.watch(safaChatAccessAllowedProvider);

    if (!accessAllowed) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.emotionOasisTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                loc.safaTrialExpiredMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: ProPaywallScreen()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.emotionOasisTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SafaMedicalDisclaimer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.emotionOasisPromptLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: loc.emotionOasisHint,
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            loc.emotionOasisAnalyze,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  if (_response.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _response.replaceAll(RegExp(r'\*\*'), ''),
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
          ),
        ],
      ),
    );
  }
}
