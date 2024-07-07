import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:love_code/portable_api/audio/audio_controller.dart';

class PlayerWaveformController extends ChangeNotifier {
  PlayerWaveformController({required this.url});
  final String url;
  bool _playing = false;
  Duration _playPosition = const Duration();
  Duration _maxDuration = const Duration();

  bool get playing => _playing;
  Duration get playPosition => _playPosition;
  Duration get maxDuration => _maxDuration;

  void setPlaying(bool val) async {
    if (val) {
      await AudioController.instance.playAudio(url);
    } else {
      await AudioController.instance.pauseAudio();
    }
    _playing = val;
    notifyListeners();
  }

  void setFinishedPlaying() {
    _playPosition = const Duration();
    _playing = false;
    Get.log('setFinishedPlaying called');
    notifyListeners();
  }

  Future<void> setPlayingPosition(Duration pos) async {
    _playPosition = pos;
    notifyListeners();
  }

  Future<void> setPlayingPositionAudio(Duration pos) async {
    await AudioController.instance.setPlayerPosition(pos);

    _playPosition = pos;
    notifyListeners();
  }

  void setMaxDuration(Duration max) {
    _maxDuration = max;
    notifyListeners();
  }

  void start() {
    setPlaying(true);
  }

  void pause() {
    setPlaying(false);
  }
}
