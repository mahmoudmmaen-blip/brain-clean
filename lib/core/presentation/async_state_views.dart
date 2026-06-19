import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Shared loading / error placeholders for async Riverpod providers.
abstract final class AsyncStateViews {
  static Widget loading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  static Widget error(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            loc.asyncErrorRetry,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
