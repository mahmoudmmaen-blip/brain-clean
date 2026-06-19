import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../ambient_sound_player.dart';

const ambientMiniPlayerKey = Key('ambient_mini_player');

/// Persistent bottom bar when ambient sound is active.
class AmbientMiniPlayer extends ConsumerWidget {
  const AmbientMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambientSoundControllerProvider);
    final sound = state.active;
    if (sound == null) return const SizedBox.shrink();

    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final controller = ref.read(ambientSoundControllerProvider.notifier);

    return Material(
      key: ambientMiniPlayerKey,
      color: AppColors.card,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(sound.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sound.localizedLabel(isArabic),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  if (state.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play(sound);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: AppColors.textSecondary),
                onPressed: controller.stop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet grid for picking ambient sounds.
Future<void> showAmbientSoundPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Consumer(
      builder: (context, ref, _) {
        final isArabic = ref.watch(localeProvider).languageCode == 'ar';
        final state = ref.watch(ambientSoundControllerProvider);
        final controller = ref.read(ambientSoundControllerProvider.notifier);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'أصوات التركيز' : 'Focus Sounds',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  for (final sound in AmbientSound.values)
                    _SoundCard(
                      sound: sound,
                      isArabic: isArabic,
                      selected: state.active == sound && state.isPlaying,
                      onTap: () => controller.toggle(sound),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.volume_up, color: AppColors.textSecondary),
                  Expanded(
                    child: Slider(
                      value: state.volume,
                      activeColor: AppColors.primary,
                      onChanged: controller.setVolume,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.isArabic,
    required this.selected,
    required this.onTap,
  });

  final AmbientSound sound;
  final bool isArabic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            '${sound.emoji} ${sound.localizedLabel(isArabic)}',
            style: const TextStyle(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

const ambientSoundToggleKey = Key('ambient_sound_toggle');

/// AppBar icon to open ambient sound picker.
class AmbientSoundToggleButton extends ConsumerWidget {
  const AmbientSoundToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      key: ambientSoundToggleKey,
      icon: const Icon(Icons.music_note_outlined),
      onPressed: () => showAmbientSoundPicker(context, ref),
    );
  }
}
