import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../content/content_repository.dart';
import '../../routing/v3_routes.dart';

class V3SosHubScreen extends ConsumerWidget {
  const V3SosHubScreen({super.key});

  IconData _icon(String id) => switch (id) {
        'phone' => Icons.phone_android,
        'hourglass' => Icons.hourglass_empty,
        'wave' => Icons.waves,
        'moon' => Icons.nightlight_round,
        _ => Icons.favorite_border,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final contentAsync = ref.watch(v3ContentProvider);

    return Scaffold(
      key: const Key('v3_sos'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(V3Routes.today);
            }
          },
        ),
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (bundle) {
          final sos = bundle.sos;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                Text(
                  sos.title.resolve(locale),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sos.subtitle.resolve(locale),
                  style: const TextStyle(
                    color: AppDesignConstants.darkOnSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                for (final flow in sos.flows) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      key: Key('v3_sos_flow_${flow.id}'),
                      onPressed: () => context.push('/sos/${flow.id}'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_icon(flow.icon), size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              flow.label.resolve(locale),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                Text(
                  loc.v3NotMedical,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppDesignConstants.darkOnSurfaceDim,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
