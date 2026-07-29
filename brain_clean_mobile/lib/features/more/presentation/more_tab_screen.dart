import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../pro/application/subscription_service_provider.dart';

/// More tab — profile, settings, pro, and app info.
class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isPro = ref.watch(isProUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.moreTabTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person_outline, color: colorScheme.primary),
            title: Text(loc.moreProfile),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(AppRoutes.profile),
          ),
          ListTile(
            leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
            title: Text(loc.moreSettings),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(AppRoutes.settings),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.workspace_premium, color: colorScheme.primary),
              title: Text(loc.settingsProCardTitle),
              subtitle: Text(
                '${isPro ? loc.settingsProStatusPro : loc.settingsProStatusFree}\n'
                '${loc.settingsProBenefitHint}',
              ),
              isThreeLine: true,
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () => context.push(AppRoutes.proPaywall),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people_outline, color: colorScheme.primary),
            title: Text(loc.moreAccountability),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(AppRoutes.accountability),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            title: Text(loc.moreVersion(AppConfig.appVersion)),
          ),
        ],
      ),
    );
  }
}
