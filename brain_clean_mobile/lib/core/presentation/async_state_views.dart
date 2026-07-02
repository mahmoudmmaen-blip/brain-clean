import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Shared loading / error placeholders for async Riverpod providers.
abstract final class AsyncStateViews {
  static Widget loading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(color: colorScheme.primary),
    );
  }

  static Widget error(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            loc.asyncErrorRetry,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
