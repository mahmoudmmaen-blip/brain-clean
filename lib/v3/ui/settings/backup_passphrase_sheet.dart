import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../data/v3_backup_crypto.dart';

/// Collects a passphrase (once or twice) for backup export/import.
Future<String?> showBackupPassphraseSheet(
  BuildContext context, {
  required bool confirmTwice,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignConstants.darkSurface,
    builder: (ctx) => _PassphraseBody(confirmTwice: confirmTwice),
  );
}

class _PassphraseBody extends StatefulWidget {
  const _PassphraseBody({required this.confirmTwice});

  final bool confirmTwice;

  @override
  State<_PassphraseBody> createState() => _PassphraseBodyState();
}

class _PassphraseBodyState extends State<_PassphraseBody> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final loc = AppLocalizations.of(context)!;
    final p = _pass.text;
    if (p.length < V3BackupCrypto.minPassphraseLength) {
      setState(() => _error = loc.v3BackupPassphraseTooShort);
      return;
    }
    if (widget.confirmTwice && p != _confirm.text) {
      setState(() => _error = loc.v3BackupPassphraseMismatch);
      return;
    }
    Navigator.of(context).pop(p);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.v3BackupPassphraseTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('v3_backup_passphrase'),
            controller: _pass,
            obscureText: true,
            decoration: InputDecoration(hintText: loc.v3BackupPassphraseHint),
          ),
          if (widget.confirmTwice) ...[
            const SizedBox(height: 8),
            TextField(
              key: const Key('v3_backup_passphrase_confirm'),
              controller: _confirm,
              obscureText: true,
              decoration: InputDecoration(
                hintText: loc.v3BackupPassphraseConfirm,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('v3_backup_passphrase_submit'),
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppDesignConstants.brandGreen,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
  }
}
