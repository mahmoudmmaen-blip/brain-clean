import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../security/security_status_provider.dart';
import '../theme/app_design_constants.dart';

/// Non-blocking banner when the device appears rooted / jailbroken.
class SecurityWarningBanner extends ConsumerWidget {
  const SecurityWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compromised = ref.watch(deviceCompromisedProvider);
    if (!compromised) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: const Color(0xFF3B1F1F),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.securityCompromisedBanner,
                  style: AppDesignConstants.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFDE68A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
