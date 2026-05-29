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
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تأكيد التشتت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'سيتم خصم 12 ساعة من تركيزك المتواصل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B949E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: Color(0xFF8B949E)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('تأكيد التشتت'),
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

    return OutlinedButton.icon(
      key: homeDistractionButtonKey,
      onPressed: _onPressed,
      icon: const Icon(Icons.hourglass_bottom_outlined),
      label: Text(loc.homeDistractionButton),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: const Color(0xFFF59E0B),
        side: const BorderSide(color: Color(0xFFF59E0B)),
      ),
    );
  }
}
