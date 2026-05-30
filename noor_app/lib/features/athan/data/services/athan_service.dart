// lib/features/athan/data/services/athan_service.dart
// Athan audio playback using just_audio

import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Athan audio sources mapping
class AthanAudioSources {
  static const Map<String, String> assets = {
    'mecca': 'assets/audio/athan_mecca.mp3',
    'madinah': 'assets/audio/athan_madinah.mp3',
    'egypt': 'assets/audio/athan_egypt.mp3',
    'turkey': 'assets/audio/athan_turkey.mp3',
    'local': 'assets/audio/athan_local.mp3',
  };

  // Fallback URLs if local assets not available
  static const Map<String, String> fallbackUrls = {
    'mecca': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
  };
}

class AthanState {
  final bool isPlaying;
  final bool isAthanTime;
  final String currentPrayerEn;
  final String currentPrayerAr;
  final double volume;

  const AthanState({
    this.isPlaying = false,
    this.isAthanTime = false,
    this.currentPrayerEn = '',
    this.currentPrayerAr = '',
    this.volume = 0.8,
  });

  AthanState copyWith({
    bool? isPlaying,
    bool? isAthanTime,
    String? currentPrayerEn,
    String? currentPrayerAr,
    double? volume,
  }) {
    return AthanState(
      isPlaying: isPlaying ?? this.isPlaying,
      isAthanTime: isAthanTime ?? this.isAthanTime,
      currentPrayerEn: currentPrayerEn ?? this.currentPrayerEn,
      currentPrayerAr: currentPrayerAr ?? this.currentPrayerAr,
      volume: volume ?? this.volume,
    );
  }
}

class AthanNotifier extends StateNotifier<AthanState> {
  final AudioPlayer _player;
  final Ref _ref;

  AthanNotifier(this._ref)
      : _player = AudioPlayer(),
        super(const AthanState()) {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _onAthanComplete();
      }
    });
  }

  Future<void> playAthan(String prayerNameEn, String prayerNameAr) async {
    final settings = _ref.read(settingsProvider);
    if (settings.isSilentMode) return;

    state = state.copyWith(
      isAthanTime: true,
      isPlaying: true,
      currentPrayerEn: prayerNameEn,
      currentPrayerAr: prayerNameAr,
      volume: settings.athanVolume,
    );

    try {
      final assetPath = AthanAudioSources.assets[settings.athanSound]
          ?? AthanAudioSources.assets['mecca']!;

      await _player.setVolume(settings.athanVolume);
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      // If asset not found, silently fail but show the UI
      state = state.copyWith(isPlaying: false);
    }
  }

  void stopAthan() {
    _player.stop();
    _onAthanComplete();
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void _onAthanComplete() {
    state = state.copyWith(
      isPlaying: false,
      isAthanTime: false,
      currentPrayerEn: '',
      currentPrayerAr: '',
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final athanProvider = StateNotifierProvider<AthanNotifier, AthanState>(
  (ref) => AthanNotifier(ref),
);
