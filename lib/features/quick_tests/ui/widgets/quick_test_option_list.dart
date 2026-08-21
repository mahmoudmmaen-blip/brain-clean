import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_constants.dart';

/// Shared MCQ / Likert option list for Phase 5 quick tests.
class QuickTestOptionList extends StatelessWidget {
  const QuickTestOptionList({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: selectedIndex == i
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppDesignConstants.minTouchTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedIndex == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectedIndex == i
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labels[i],
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

/// Likert 1–5 labels reused from Brain Check.
List<(int, String)> quickTestLikertOptions(AppLocalizations loc) {
  return [
    (1, loc.brainCheckLikert1),
    (2, loc.brainCheckLikert2),
    (3, loc.brainCheckLikert3),
    (4, loc.brainCheckLikert4),
    (5, loc.brainCheckLikert5),
  ];
}
