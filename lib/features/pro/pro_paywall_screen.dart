import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/l10n/app_localizations.dart';

const proPaywallKey = Key('pro_paywall_screen');
const proSubscribeKey = Key('pro_subscribe_button');

/// Mock Pro subscription paywall — no real payment integration.
class ProPaywallScreen extends ConsumerWidget {
  const ProPaywallScreen({super.key});

  Future<void> _activatePro(BuildContext context, WidgetRef ref) async {
    await ref.read(appPreferencesProvider.notifier).setProUser(true);
    if (!context.mounted) return;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.proWelcomeSnack),
        backgroundColor: const Color(0xFF1D9E75),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final features = [
      loc.proFeatureAdvancedBcs,
      loc.proFeatureSevenDayChart,
      loc.proFeatureEmotionWheel,
      loc.proFeatureFocusChallenges,
      loc.proFeatureCloudSync,
    ];

    return Scaffold(
      key: proPaywallKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                  onPressed: () => context.pop(),
                ),
              ),
              const Icon(
                Icons.workspace_premium,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              Text(
                loc.proPaywallTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.proPaywallSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8B949E)),
              ),
              const SizedBox(height: 32),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1D9E75),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: Color(0xFFE6EDF3),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.proPriceMonthly,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6EDF3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.proPriceHint,
                      style: const TextStyle(color: Color(0xFF8B949E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D9E75), Color(0xFF0F7A5A)],
                  ),
                ),
                child: ElevatedButton(
                  key: proSubscribeKey,
                  onPressed: () => _activatePro(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loc.proSubscribeNow,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _activatePro(context, ref),
                child: Text(
                  loc.proRestorePurchase,
                  style: const TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
