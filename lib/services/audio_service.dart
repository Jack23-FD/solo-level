import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static AudioPlayer? _levelPlayer;
  static AudioPlayer? _splashPlayer;
  static AudioPlayer? _pagePlayer;

  static AudioPlayer get levelPlayer => _levelPlayer ??= AudioPlayer();
  static AudioPlayer get splashPlayer => _splashPlayer ??= AudioPlayer();
  static AudioPlayer get pagePlayer => _pagePlayer ??= AudioPlayer();

  static DateTime? _lastPlayTime;
  static DateTime? _lastPageSoundTime;

  /// Play level up sound effect
  static Future<void> playLevelUp() async {
    final now = DateTime.now();
    if (_lastPlayTime != null &&
        now.difference(_lastPlayTime!) < const Duration(milliseconds: 400)) {
      return;
    }
    _lastPlayTime = now;

    try {
      await levelPlayer.stop();
      await levelPlayer.play(AssetSource('audio/level_up.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio play error (level_up.mp3): $e');
    }
  }

  /// Play splash screen loading sound (loadingpage.mp3)
  static Future<void> playSplashLoading() async {
    try {
      await splashPlayer.stop();
      await splashPlayer.play(AssetSource('audio/loadingpage.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('Audio play error (loadingpage.mp3): $e');
    }
  }

  /// Stop splash screen loading sound
  static Future<void> stopSplashLoading() async {
    try {
      await splashPlayer.stop();
    } catch (_) {}
  }

  /// Play page transition sound effect (page.mp3 / page.wav)
  static Future<void> playPageChange() async {
    final now = DateTime.now();
    if (_lastPageSoundTime != null &&
        now.difference(_lastPageSoundTime!) < const Duration(milliseconds: 100)) {
      return;
    }
    _lastPageSoundTime = now;

    try {
      await pagePlayer.stop();
      await pagePlayer.play(AssetSource('audio/page.mp3'), volume: 1.0);
    } catch (_) {
      try {
        await pagePlayer.stop();
        await pagePlayer.play(AssetSource('audio/page.wav'), volume: 1.0);
      } catch (err) {
        debugPrint('Audio play error (page sound): $err');
      }
    }
  }
}
