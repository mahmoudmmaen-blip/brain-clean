import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/daily_quotes.dart';

const dailyQuoteCardKey = Key('daily_quote_card');

/// Science-based daily brain quote — same quote all day, locale-aware.
class DailyQuoteCard extends ConsumerWidget {
  const DailyQuoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final quote = quoteForDate(DateTime.now());

    return Container(
      key: dailyQuoteCardKey,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161B22), Color(0xFF1A2332)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.format_quote,
            color: AppColors.primary.withValues(alpha: 0.4),
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  quote.forLocale(isArabic),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.dailyQuoteSource,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
