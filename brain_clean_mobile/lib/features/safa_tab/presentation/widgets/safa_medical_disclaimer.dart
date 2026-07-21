import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Small, always-visible medical disclaimer for Safa screens.
class SafaMedicalDisclaimer extends StatelessWidget {
  const SafaMedicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        loc.safaMedicalDisclaimer,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.35,
        ),
      ),
    );
  }
}
