import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../data/anxiety_repository_provider.dart';
import '../domain/anxiety_scoring.dart';
import 'anxiety_latest_result_provider.dart';
import 'anxiety_localization.dart';

/// Eight-question chronic anxiety questionnaire — one question per page.
class AnxietyDiagnosticScreen extends ConsumerStatefulWidget {
  const AnxietyDiagnosticScreen({super.key});

  @override
  ConsumerState<AnxietyDiagnosticScreen> createState() =>
      _AnxietyDiagnosticScreenState();
}

class _AnxietyDiagnosticScreenState
    extends ConsumerState<AnxietyDiagnosticScreen> {
  late final PageController _pageController;
  final List<int?> _answers = List<int?>.filled(AnxietyScoring.questionCount, null);
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onOptionSelected(int questionIndex, int value) async {
    if (_isSubmitting) return;

    setState(() => _answers[questionIndex] = value);

    final isLast = questionIndex >= AnxietyScoring.questionCount - 1;
    if (!isLast) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = questionIndex + 1);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = AnxietyScoring.buildResult(
        _answers.cast<int>(),
      );
      await ref.read(anxietyRepositoryProvider).saveResult(result);
      ref.invalidate(anxietyLatestResultProvider);
      if (!mounted) return;
      context.push(AppRoutes.anxietyResult);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.anxietySaveError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final options = anxietyOptionLabels(loc);
    final progress = (_currentPage + 1) / AnxietyScoring.questionCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.anxietyScreenTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.anxietyProgressLabel(
                    _currentPage + 1,
                    AnxietyScoring.questionCount,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AnxietyScoring.questionCount,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final selected = _answers[index];
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Text(
                        anxietyQuestionFor(loc, index),
                        textAlign: TextAlign.center,
                        style: AppDesignConstants.arabicText(
                          fontSize: AppDesignConstants.arabicQuestionFontSize,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          height: AppDesignConstants.arabicQuestionLineHeight,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ...List.generate(options.length, (optionIndex) {
                        final isSelected = selected == optionIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FilterChip(
                            label: Text(
                              options[optionIndex],
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: _isSubmitting
                                ? null
                                : (_) => _onOptionSelected(index, optionIndex),
                            selectedColor: colorScheme.primary,
                            backgroundColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        );
                      }),
                      const Spacer(flex: 2),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isSubmitting)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
