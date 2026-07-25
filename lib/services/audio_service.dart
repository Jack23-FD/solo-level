import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  /// Play level up / rank system sound effect
  static Future<void> playLevelUp() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/level_up.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio play error (level_up.mp3): $e');
    }
  }
}
