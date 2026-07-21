import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';

/// Compact one-liner + info icon that opens a metric explanation sheet.
///
/// Sheet shell matches the daily-program confirmation bottom sheet:
/// surface panel, top handle, title, body, action button.
class MetricInfoRow extends StatelessWidget {
  const MetricInfoRow({
    super.key,
    required this.oneLiner,
    required this.fullExplanation,
    required this.sheetTitle,
    this.compact = false,
  });

  final String oneLiner;
  final String fullExplanation;
  final String sheetTitle;

  /// Tighter padding/font for chart legends and dense cards.
  final bool compact;

  Future<void> _openSheet(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.14),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      sheetTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullExplanation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(loc.commonOk),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final fontSize = compact ? 11.0 : 12.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            oneLiner,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: fontSize,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            tooltip: loc.metricInfoA11yLabel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(
              Icons.info_outline,
              size: compact ? 18 : 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _openSheet(context),
          ),
        ),
      ],
    );
  }
}
