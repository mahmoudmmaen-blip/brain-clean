import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_provider.dart';

const languageToggleKey = Key('language_toggle_button');

/// AppBar action — toggles AR ↔ EN with flag emoji.
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final flag = localeFlagEmoji(locale);
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      key: languageToggleKey,
      tooltip: flag,
      onPressed: () => toggleLocale(ref),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(flag, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
