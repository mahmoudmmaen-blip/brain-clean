import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/social_media_usage_provider.dart';
import '../../../shared/widgets/glass_card.dart';

const socialMediaUsageHomeCardKey = Key('social_media_usage_home_card');

/// Home card: gentle view-only social media time (Android Usage Access).
class SocialMediaUsageHomeCard extends ConsumerStatefulWidget {
  const SocialMediaUsageHomeCard({super.key});

  @override
  ConsumerState<SocialMediaUsageHomeCard> createState() =>
      _SocialMediaUsageHomeCardState();
}

class _SocialMediaUsageHomeCardState extends ConsumerState<SocialMediaUsageHomeCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socialMediaUsageProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(socialMediaUsageProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Android-only card; hide on Web/iOS/desktop without dart:io Platform.
    final service = ref.watch(socialMediaUsageServiceProvider);
    if (!service.isSupported) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final usageAsync = ref.watch(socialMediaUsageProvider);

    return usageAsync.when(
      loading: () => GlassCard(
        key: socialMediaUsageHomeCardKey,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.socialMediaUsageLoading,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (snapshot) {
        if (!snapshot.hasAccess) {
          return GlassCard(
            key: socialMediaUsageHomeCardKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      color: colorScheme.primary,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.socialMediaUsagePromptTitle,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  loc.socialMediaUsagePromptBody,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref
                      .read(socialMediaUsageProvider.notifier)
                      .openUsageAccessSettings(),
                  child: Text(loc.socialMediaUsageGrantButton),
                ),
              ],
            ),
          );
        }

        return GlassCard(
          key: socialMediaUsageHomeCardKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.hourglass_bottom_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.socialMediaUsageTodayTotal(snapshot.totalMinutes),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.socialMediaUsageTodaySubtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
