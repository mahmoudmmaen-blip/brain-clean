import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/sos_now_provider.dart';
import '../../content/content_repository.dart';
import '../../content/sos_content.dart';
import '../../domain/sos_night.dart';
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
    final now = ref.watch(sosNowProvider);
    final night = isSosNightWindow(now);

    final bg = night ? const Color(0xFF050508) : AppDesignConstants.darkBackground;
    final muted = night
        ? AppDesignConstants.darkOnSurfaceDim
        : AppDesignConstants.darkOnSurfaceMuted;

    return Scaffold(
      key: const Key('v3_sos'),
      backgroundColor: bg,
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
          final flows = orderSosFlowsForTime<SosFlow>(
            flows: sos.flows,
            idOf: (f) => f.id,
            local: now,
          );
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                Text(
                  sos.title.resolve(locale),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: night
                        ? AppDesignConstants.darkOnSurfaceMuted
                        : AppDesignConstants.darkOnSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sos.subtitle.resolve(locale),
                  style: TextStyle(color: muted, height: 1.4),
                ),
                const SizedBox(height: 24),
                for (final flow in flows) ...[
                  _FlowButton(
                    flow: flow,
                    locale: locale,
                    icon: _icon(flow.icon),
                    highlighted: night && flow.id == 'sos_sleep',
                    night: night,
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                Text(
                  loc.v3NotMedical,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: night
                        ? const Color(0xFF555555)
                        : AppDesignConstants.darkOnSurfaceDim,
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

class _FlowButton extends StatelessWidget {
  const _FlowButton({
    required this.flow,
    required this.locale,
    required this.icon,
    required this.highlighted,
    required this.night,
  });

  final SosFlow flow;
  final String locale;
  final IconData icon;
  final bool highlighted;
  final bool night;

  @override
  Widget build(BuildContext context) {
    final label = flow.label.resolve(locale);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        key: Key('v3_sos_flow_${flow.id}'),
        onPressed: () => context.push('/sos/${flow.id}'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: highlighted
              ? AppDesignConstants.brandGreen.withValues(alpha: 0.22)
              : (night
                  ? AppDesignConstants.darkSurfaceSecondary
                      .withValues(alpha: 0.7)
                  : null),
          side: highlighted
              ? const BorderSide(color: AppDesignConstants.brandGreen, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: highlighted ? AppDesignConstants.brandGreen : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
