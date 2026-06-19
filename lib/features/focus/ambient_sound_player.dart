import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AmbientSound {
  rain('rain', '🌧️', 'مطر', 'Rain', 'assets/sounds/rain.mp3'),
  waves('waves', '🌊', 'أمواج', 'Waves', 'assets/sounds/waves.mp3'),
  forest('forest', '🌿', 'غابة', 'Forest', 'assets/sounds/forest.mp3'),
  whiteNoise(
    'white_noise',
    '⬜',
    'ضوضاء بيضاء',
    'White Noise',
    'assets/sounds/white_noise.mp3',
  ),
  brownNoise(
    'brown_noise',
    '🟤',
    'ضوضاء بنية',
    'Brown Noise',
    'assets/sounds/brown_noise.mp3',
  );

  const AmbientSound(
    this.id,
    this.emoji,
    this.labelAr,
    this.labelEn,
    this.assetPath,
  );

  final String id;
  final String emoji;
  final String labelAr;
  final String labelEn;
  final String assetPath;

  String localizedLabel(bool isArabic) => isArabic ? labelAr : labelEn;
}

class AmbientSoundState {
  const AmbientSoundState({
    this.active,
    this.isPlaying = false,
    this.volume = 0.6,
  });

  final AmbientSound? active;
  final bool isPlaying;
  final double volume;

  AmbientSoundState copyWith({
    AmbientSound? active,
    bool? isPlaying,
    double? volume,
    bool clearActive = false,
  }) {
    return AmbientSoundState(
      active: clearActive ? null : (active ?? this.active),
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}

class AmbientSoundController extends StateNotifier<AmbientSoundState> {
  AmbientSoundController() : super(const AmbientSoundState());

  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);

  Future<void> play(AmbientSound sound) async {
    try {
      await _player.stop();
      await _player.setVolume(state.volume);
      await _player.play(AssetSource(sound.assetPath.replaceFirst('assets/', '')));
      state = AmbientSoundState(
        active: sound,
        isPlaying: true,
        volume: state.volume,
      );
    } catch (_) {
      state = AmbientSoundState(
        active: sound,
        isPlaying: false,
        volume: state.volume,
      );
    }
  }

  Future<void> toggle(AmbientSound sound) async {
    if (state.active == sound && state.isPlaying) {
      await pause();
    } else {
      await play(sound);
    }
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AmbientSoundState();
  }

  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    await _player.setVolume(v);
    state = state.copyWith(volume: v);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final ambientSoundControllerProvider =
    StateNotifierProvider<AmbientSoundController, AmbientSoundState>(
  (ref) => AmbientSoundController(),
);
