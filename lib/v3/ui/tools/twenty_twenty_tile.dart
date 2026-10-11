import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../application/twenty_twenty_service.dart';

class TwentyTwentyTile extends ConsumerWidget {
  const TwentyTwentyTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(twentyTwentyControllerProvider);

    return Card(
      key: const Key('v3_tools_twenty'),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(loc.v3ToolsTwentyTitle),
            subtitle: Text(loc.v3ToolsTwentyBody),
            value: settings.enabled,
            onChanged: (v) =>
                ref.read(twentyTwentyControllerProvider.notifier).setEnabled(v),
          ),
          if (settings.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(loc.v3ToolsTwentyHours),
                  ),
                  DropdownButton<int>(
                    key: const Key('v3_twenty_start'),
                    value: settings.startHour,
                    items: [
                      for (var h = 6; h <= 20; h++)
                        DropdownMenuItem(value: h, child: Text('$h:00')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(twentyTwentyControllerProvider.notifier).setHours(
                            startHour: v,
                            endHour: settings.endHour,
                          );
                    },
                  ),
                  const Text(' — '),
                  DropdownButton<int>(
                    key: const Key('v3_twenty_end'),
                    value: settings.endHour,
                    items: [
                      for (var h = 8; h <= 23; h++)
                        DropdownMenuItem(value: h, child: Text('$h:00')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(twentyTwentyControllerProvider.notifier).setHours(
                            startHour: settings.startHour,
                            endHour: v,
                          );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
