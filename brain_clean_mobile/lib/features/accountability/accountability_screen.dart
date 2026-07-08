import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import 'accountability_box_modal.dart';

/// Full-screen accountability room entry (opens the accountability modal).
class AccountabilityScreen extends ConsumerStatefulWidget {
  const AccountabilityScreen({super.key});

  @override
  ConsumerState<AccountabilityScreen> createState() =>
      _AccountabilityScreenState();
}

class _AccountabilityScreenState extends ConsumerState<AccountabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAccountabilityBoxModal(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.accountabilityRoomTitle)),
      body: Center(
        child: FilledButton(
          onPressed: () => showAccountabilityBoxModal(context),
          child: Text(loc.homeAccountabilityBox),
        ),
      ),
    );
  }
}
