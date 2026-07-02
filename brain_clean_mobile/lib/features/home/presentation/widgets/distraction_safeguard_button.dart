import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../home_streak_provider.dart';

const homeDistractionButtonKey = Key('home_distraction_button');

/// Temporary distraction — debounced tap + confirmation bottom sheet + 12h retrograde.
class DistractionSafeguardButton extends ConsumerStatefulWidget {
  const DistractionSafeguardButton({super.key});

  @override
  ConsumerState<DistractionSafeguardButton> createState() =>
      _DistractionSafeguardButtonState();
}

class _DistractionSafeguardButtonState
    extends ConsumerState<DistractionSafeguardButton> {
  bool _isTapLocked = false;

  void _applyDistraction() {
    ref.read(homeStreakRetrogradeProvider.notifier).applyHours(12);
  }

  Future<void> _onPressed() async {
    if (_isTapLocked) return;
    _isTapLocked = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _isTapLocked = false;
    });

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        final colorScheme = Theme.of(ctx).colorScheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc.homeDistractionConfirmTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.homeDistractionConfirmMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(
                          loc.homeDistractionCancel,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(loc.homeDistractionConfirmAction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      _applyDistraction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      key: homeDistractionButtonKey,
      onPressed: _onPressed,
      icon: const Icon(Icons.hourglass_bottom_outlined),
      label: Text(loc.homeDistractionButton),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
      ),
    );
  }
}
