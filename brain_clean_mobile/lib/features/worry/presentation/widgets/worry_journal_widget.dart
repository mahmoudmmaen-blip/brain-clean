import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_constants.dart';

/// Shared RTL journal text field for worry window + journal screens.
class WorryJournalWidget extends StatelessWidget {
  const WorryJournalWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.minLines = 4,
    this.maxLines = 12,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      minLines: minLines,
      maxLines: maxLines,
      style: AppDesignConstants.arabicText(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: AppDesignConstants.arabicBodyLineHeight,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
