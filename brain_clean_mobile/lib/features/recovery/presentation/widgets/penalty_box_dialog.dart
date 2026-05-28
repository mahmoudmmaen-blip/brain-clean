import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/recovery_protocol_constants.dart';

/// Confirmation dialog for صندوق العقابات — red confirm, gray cancel.
Future<bool> showPenaltyBoxDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(loc.recoveryPenaltyBoxTitle),
      content: Text(
        loc.recoveryPenaltyBoxMessage(
          RecoveryProtocolConstants.penaltyBcScoreDeduction,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(loc.recoveryPenaltyCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          child: Text(loc.recoveryPenaltyConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
