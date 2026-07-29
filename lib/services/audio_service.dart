import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static DateTime? _lastPlayTime;

  /// Play level up / rank system sound effect with debounce and overlap prevention
  static Future<void> playLevelUp() async {
    final now = DateTime.now();
    if (_lastPlayTime != null &&
        now.difference(_lastPlayTime!) < const Duration(milliseconds: 600)) {
      return;
    }
    _lastPlayTime = now;

    try {
      await _player.stop();
      await _player.play(AssetSource('audio/level_up.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio play error (level_up.mp3): $e');
    }
  }
}
