import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/hive_meta_keys.dart';
import '../../core/data/app_meta_box_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/app_notification_service.dart';
import 'application/displayed_xp_provider.dart';
import 'level_system.dart';

const levelProgressWidgetKey = Key('level_progress_widget');

/// Verified cumulative XP — server-preferred when online, else local ledger.
final cumulativeBcsScoreProvider = Provider<int>((ref) {
  return ref.watch(displayedXpSyncProvider);
});

/// Shows current brain level, progress bar, and confetti on level-up.
class LevelProgressWidget extends ConsumerStatefulWidget {
  const LevelProgressWidget({super.key});

  @override
  ConsumerState<LevelProgressWidget> createState() =>
      _LevelProgressWidgetState();
}

class _LevelProgressWidgetState extends ConsumerState<LevelProgressWidget> {
  late ConfettiController _confetti;
  bool _checkedLevel = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _maybeCelebrateLevelUp(BrainLevel level) async {
    if (_checkedLevel) return;
    _checkedLevel = true;
    try {
      final box = ref.read(appMetaBoxProvider);
      final lastIndex =
          box.get(HiveMetaKeys.lastKnownBrainLevel, defaultValue: 0) as int;
      if (level.index > lastIndex) {
        await box.put(HiveMetaKeys.lastKnownBrainLevel, level.index);
        _confetti.play();
        final isArabic = ref.read(localeProvider).languageCode == 'ar';
        final name = level.localizedName(isArabic);
        await ref.read(appNotificationServiceProvider).showSimple(
              id: 9001,
              title: isArabic ? 'تهانينا! 🎉' : 'Congrats! 🎉',
              body: isArabic
                  ? 'تهانينا! وصلت لمستوى $name 🎉'
                  : 'Congrats! You reached $name level 🎉',
            );
      }
    } catch (_) {
      // Best-effort celebration.
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final score = ref.watch(cumulativeBcsScoreProvider);
    final level = BrainLevel.forScore(score);
    final progress = BrainLevel.progressToNext(score);
    final pointsLeft = BrainLevel.pointsToNextLevel(score);
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeCelebrateLevelUp(level);
    });

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          key: levelProgressWidgetKey,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(level.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      level.localizedName(isArabic),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: dividerColor,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.levelPointsToNext(pointsLeft),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 24,
          gravity: 0.2,
        ),
      ],
    );
  }
}
