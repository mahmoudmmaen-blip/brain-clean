import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../pro/pro_paywall_screen.dart';
import '../application/safa_trial_provider.dart';
import 'widgets/safa_medical_disclaimer.dart';

/// Safa AI companion tab — 7-day free trial, then Pro paywall.
class SafaTabScreen extends ConsumerStatefulWidget {
  const SafaTabScreen({super.key});

  @override
  ConsumerState<SafaTabScreen> createState() => _SafaTabScreenState();
}

class _SafaTabScreenState extends ConsumerState<SafaTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(safaTrialControllerProvider.notifier).recordFirstVisitIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final accessAllowed = ref.watch(safaChatAccessAllowedProvider);

    if (!accessAllowed) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.safaTabTitle),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                loc.safaTrialExpiredMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Expanded(child: ProPaywallScreen()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.safaTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          const SafaMedicalDisclaimer(),
          Expanded(
            child: Padding(
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
          ),
        ],
      ),
    );
  }
}
