import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:love_code/portable_api/audio/audio_controller.dart';

class PlayerWaveformController extends ChangeNotifier {
  PlayerWaveformController({required this.url});
  final String url;
  bool _playing = false;
  Duration _playPosition = Duration();
  Duration _maxDuration = Duration();

  bool get playing => _playing;
  Duration get playPosition => _playPosition;
  Duration get maxDuration => _maxDuration;

  void setPlaying(bool val) async {
    _playing = val;
    if (_playing) {
      AudioController.instance.playAudio(url);
    } else {
      AudioController.instance.pauseAudio();
    }
    notifyListeners();
  }

  void setFinishedPlaying() {
    _playPosition = Duration();
    _playing = false;
    Get.log('setFinishedPlaying called');
    notifyListeners();
  }

  void setPlayingPosition(Duration pos) {
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
