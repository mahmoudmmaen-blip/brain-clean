import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows the app's standard confirmation dialog and resolves to `true` only
/// when the confirm action is tapped.
///
/// When [destructive] is true the confirm label is tinted with
/// [AppColors.danger].
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
  bool barrierDismissible = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            cancelLabel,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style:
                destructive ? const TextStyle(color: AppColors.danger) : null,
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
