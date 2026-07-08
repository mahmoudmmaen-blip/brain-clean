import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../pro/pro_gate.dart';

/// Safa AI companion tab — pro-gated emotion oasis entry.
class SafaTabScreen extends ConsumerWidget {
  const SafaTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isPro = ref.watch(isProUserProvider);

    if (!isPro) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.safaTabTitle),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: const ProGate(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.safaTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 56,
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              child: Icon(
                Icons.smart_toy,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.safaTabSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.emotionOasis),
                child: Text(loc.safaTalkButton),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.emotionOasis),
                child: Text(loc.safaOasisButton),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
