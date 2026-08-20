import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class DiagAnswerOptions extends StatelessWidget {
  const DiagAnswerOptions({
    super.key,
    required this.loc,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations loc;
  final int? selected;
  final ValueChanged<int> onSelected;

  List<(int, String)> _options() {
    return [
      (1, loc.brainCheckLikert1),
      (2, loc.brainCheckLikert2),
      (3, loc.brainCheckLikert3),
      (4, loc.brainCheckLikert4),
      (5, loc.brainCheckLikert5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = _options();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (value, label) in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: selected == value
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected == value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected == value
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
